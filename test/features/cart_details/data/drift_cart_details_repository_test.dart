import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cart_details/application/commands/cart_details_command.dart';
import 'package:margaritaville_flutter/features/cart_details/data/repositories/drift_cart_details_repository.dart';
import 'package:margaritaville_flutter/features/cart_details/domain/catalogs/cart_consumable_catalog.dart';
import 'package:margaritaville_flutter/features/cart_details/domain/repositories/cart_details_repository.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftCartDetailsRepository repository;
  late WorkSession session;
  late String assignmentId;

  setUp(() async {
    database = AppDatabase.inMemory();
    repository = DriftCartDetailsRepository(database);
    session = _session();
    assignmentId = session.activeAssignments.first.id;
    await DriftWorkSessionRepository(database).replaceSession(session);
  });

  tearDown(() => database.close());

  test('loads the exact six-item donor catalog', () async {
    final snapshot = await repository.load(
      sessionId: session.id,
      assignmentId: assignmentId,
    );

    expect(
      snapshot.consumables.map((item) => item.id),
      CartConsumableCatalog.entries.map((entry) => entry.id),
    );
    expect(snapshot.consumables.map((item) => item.title), [
      'Полотенца банные',
      'Полотенца ручные',
      'Салфетки',
      'Коврики',
      'Простыни',
      'Наволочки',
    ]);
    expect(snapshot.consumables.every((item) => item.quantity == 0), isTrue);
  });

  test('note LWW preserves microsecond order inside one second', () async {
    final base = DateTime.utc(2027, 2, 10, 12, 30, 0, 100);
    Future<CartDetailsCommitStatus> save(
      String id,
      String text,
      DateTime issuedAt,
    ) {
      return repository.commit(
        SaveCartNoteCommand(
          commandId: id,
          sessionId: session.id,
          assignmentId: assignmentId,
          issuedAt: issuedAt,
          text: text,
        ),
      );
    }

    expect(
      await save('note-a', 'Первая', base),
      CartDetailsCommitStatus.applied,
    );
    expect(
      await save('note-b', 'Новее', base.add(const Duration(microseconds: 1))),
      CartDetailsCommitStatus.applied,
    );
    expect(
      await save(
        'note-z',
        'Старая',
        base.subtract(const Duration(microseconds: 1)),
      ),
      CartDetailsCommitStatus.ignored,
    );

    final snapshot = await repository.load(
      sessionId: session.id,
      assignmentId: assignmentId,
    );
    expect(snapshot.note, 'Новее');
    expect(snapshot.noteUpdatedAt, base.add(const Duration(microseconds: 1)));
  });

  test(
    'quantity, completion, zero clearing, and duplicate are durable',
    () async {
      final changedAt = DateTime.utc(2027, 2, 10, 13);
      final quantity = SetCartConsumableQuantityCommand(
        commandId: 'quantity-1',
        sessionId: session.id,
        assignmentId: assignmentId,
        issuedAt: changedAt,
        itemId: 'bath_towel',
        title: 'Полотенца банные',
        quantity: 4,
      );
      expect(
        await repository.commit(quantity),
        CartDetailsCommitStatus.applied,
      );
      expect(
        await repository.commit(quantity),
        CartDetailsCommitStatus.duplicate,
      );

      expect(
        await repository.commit(
          SetCartConsumableCompletionCommand(
            commandId: 'complete-1',
            sessionId: session.id,
            assignmentId: assignmentId,
            issuedAt: changedAt.add(const Duration(microseconds: 1)),
            itemId: 'bath_towel',
            title: 'Полотенца банные',
            isCompleted: true,
          ),
        ),
        CartDetailsCommitStatus.applied,
      );
      expect(
        await repository.commit(
          SetCartConsumableQuantityCommand(
            commandId: 'zero-1',
            sessionId: session.id,
            assignmentId: assignmentId,
            issuedAt: changedAt.add(const Duration(microseconds: 2)),
            itemId: 'bath_towel',
            title: 'Полотенца банные',
            quantity: 0,
          ),
        ),
        CartDetailsCommitStatus.applied,
      );

      final item = (await repository.load(
        sessionId: session.id,
        assignmentId: assignmentId,
      )).consumables.first;
      expect(item.quantity, 0);
      expect(item.isCompleted, isFalse);
      expect(
        await database.select(database.historyEventRecords).get(),
        hasLength(3),
      );
    },
  );

  test('graph replacement does not erase assignment content', () async {
    await repository.commit(
      SaveCartNoteCommand(
        commandId: 'note-survives',
        sessionId: session.id,
        assignmentId: assignmentId,
        issuedAt: DateTime.utc(2027, 2, 10, 13),
        text: 'Не стирать',
      ),
    );

    await DriftWorkSessionRepository(database).replaceSession(session);

    final snapshot = await repository.load(
      sessionId: session.id,
      assignmentId: assignmentId,
    );
    expect(snapshot.note, 'Не стирать');
  });

  test('missing assignment is ignored without a false event', () async {
    final status = await repository.commit(
      SaveCartNoteCommand(
        commandId: 'missing-assignment',
        sessionId: session.id,
        assignmentId: 'missing',
        issuedAt: DateTime.utc(2027, 2, 10, 13),
        text: 'Не применять',
      ),
    );
    expect(status, CartDetailsCommitStatus.ignored);
    expect(await database.select(database.historyEventRecords).get(), isEmpty);
    expect(await database.select(database.syncOutboxRecords).get(), isEmpty);
  });

  test('note body never enters history or outbox payload', () async {
    await repository.commit(
      SaveCartNoteCommand(
        commandId: 'private-note',
        sessionId: session.id,
        assignmentId: assignmentId,
        issuedAt: DateTime.utc(2027, 2, 10, 13),
        text: 'Секретный текст заметки',
      ),
    );
    final event =
        (await database.select(database.historyEventRecords).get()).single;
    expect(event.payloadJson, isNot(contains('Секретный')));
    expect(jsonDecode(event.payloadJson), {'assignmentId': assignmentId});
  });

  test('quantity outside donor range is rejected before receipt', () async {
    await expectLater(
      repository.commit(
        SetCartConsumableQuantityCommand(
          commandId: 'invalid-quantity',
          sessionId: session.id,
          assignmentId: assignmentId,
          issuedAt: DateTime.utc(2027, 2, 10, 13),
          itemId: 'bath_towel',
          title: 'Полотенца банные',
          quantity: 11,
        ),
      ),
      throwsRangeError,
    );
    expect(
      await database.select(database.commandReceiptRecords).get(),
      isEmpty,
    );
  });
}

WorkSession _session() {
  final fixture =
      jsonDecode(
            File(
              'test/fixtures/canonical_work_session_v2.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  return WorkSession.fromJson(fixture);
}
