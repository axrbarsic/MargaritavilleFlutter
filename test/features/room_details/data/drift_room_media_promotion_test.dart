import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/data/repositories/drift_room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/pending_room_media_promotion.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftRoomDetailsRepository detailsRepository;
  late DriftRoomMediaPromotionRepository repository;

  setUp(() async {
    database = AppDatabase.inMemory();
    detailsRepository = DriftRoomDetailsRepository(database);
    repository = DriftRoomMediaPromotionRepository(database);
    await DriftWorkSessionRepository(database).replaceSession(_session());
  });

  tearDown(() => database.close());

  test('promotion journal survives until media commit is published', () async {
    final promotion = _promotion();

    await repository.stageMediaPromotion(promotion);

    expect(await repository.pendingMediaPromotions(), [promotion]);
    expect(
      (await detailsRepository.load(
        sessionId: 'session-2027-02-10',
        roomNumber: '101',
      )).media,
      isEmpty,
    );

    expect(
      await repository.completeMediaPromotion(promotion.operationId),
      RoomDetailsCommitStatus.applied,
    );
    expect(await repository.pendingMediaPromotions(), isEmpty);
    final snapshot = await detailsRepository.load(
      sessionId: 'session-2027-02-10',
      roomNumber: '101',
    );
    expect(snapshot.media.single, promotion.media);
  });

  test(
    'identical journal retry is idempotent and conflict is rejected',
    () async {
      final promotion = _promotion();
      await repository.stageMediaPromotion(promotion);
      await repository.stageMediaPromotion(promotion);

      final conflict = PendingRoomMediaPromotion(
        operationId: promotion.operationId,
        commandId: promotion.commandId,
        media: promotion.media.copyWith(checksumSha256: 'different'),
        stagedRelativePath: promotion.stagedRelativePath,
        transientFilePath: promotion.transientFilePath,
        byteLength: promotion.byteLength,
      );
      await expectLater(
        repository.stageMediaPromotion(conflict),
        throwsStateError,
      );
      expect(await repository.pendingMediaPromotions(), [promotion]);
    },
  );

  test(
    'verified duplicate removes the journal without a second event',
    () async {
      final promotion = _promotion();
      await repository.stageMediaPromotion(promotion);
      expect(
        await repository.completeMediaPromotion(promotion.operationId),
        RoomDetailsCommitStatus.applied,
      );

      await repository.stageMediaPromotion(promotion);
      expect(
        await repository.completeMediaPromotion(promotion.operationId),
        RoomDetailsCommitStatus.duplicate,
      );
      expect(await repository.pendingMediaPromotions(), isEmpty);
      expect(
        await database.select(database.historyEventRecords).get(),
        hasLength(1),
      );
    },
  );

  test(
    'discard removes only journal state and never publishes media',
    () async {
      final promotion = _promotion();
      await repository.stageMediaPromotion(promotion);

      await repository.discardMediaPromotion(promotion.operationId);

      expect(await repository.pendingMediaPromotions(), isEmpty);
      expect(
        await database.select(database.mediaManifestRecords).get(),
        isEmpty,
      );
      expect(
        await database.select(database.historyEventRecords).get(),
        isEmpty,
      );
    },
  );

  test(
    'terminal failure is quarantined without blocking later recovery',
    () async {
      final promotion = _promotion();
      await repository.stageMediaPromotion(promotion);

      final detectedAt = DateTime.utc(2027, 2, 10, 13);
      await repository.quarantineMediaPromotion(
        promotion.operationId,
        reason: 'checksum conflict',
        detectedAt: detectedAt,
      );

      expect(await repository.pendingMediaPromotions(), isEmpty);
      final row = await database
          .select(database.mediaPromotionRecords)
          .getSingle();
      expect(row.quarantinedAt, detectedAt);
      expect(row.failureReason, 'checksum conflict');
      expect(
        await database.select(database.mediaManifestRecords).get(),
        isEmpty,
      );
    },
  );
}

PendingRoomMediaPromotion _promotion() {
  final capturedAt = DateTime.utc(2027, 2, 10, 12, 45);
  return PendingRoomMediaPromotion(
    operationId: 'photo-operation-1',
    commandId: 'room-photo:photo-media-1',
    stagedRelativePath: 'Media/.staging/photo-media-1.jpg.partial',
    transientFilePath: '/camera-cache/photo-media-1.jpg',
    byteLength: 4096,
    media: RoomMediaItem(
      id: 'photo-media-1',
      sessionId: 'session-2027-02-10',
      roomNumber: '101',
      kind: RoomMediaKind.photo,
      relativePath: 'Media/photo-media-1.jpg',
      checksumSha256: 'photo-sha256',
      originDeviceId: 'iphone-17-pro-max',
      createdAt: capturedAt,
      updatedAt: capturedAt,
      mimeType: 'image/jpeg',
      byteLength: 4096,
      widthPixels: 4032,
      heightPixels: 3024,
      originalExtension: 'jpg',
      orientation: 1,
      colorSpace: 'Display P3',
      isHdr: false,
    ),
  );
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
