import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/clock_provider.dart';
import '../../../../shared/persistence/app_database_provider.dart';
import '../../application/housekeeper_catalog_command_handler.dart';
import '../../data/repositories/drift_housekeeper_catalog_repository.dart';
import '../../domain/commands/housekeeper_catalog_command.dart';
import '../../domain/models/housekeeper.dart';
import '../../domain/models/housekeeper_catalog_mutation.dart';
import '../../domain/repositories/housekeeper_catalog_repository.dart';

final housekeeperCatalogRepositoryProvider =
    Provider<HousekeeperCatalogRepository>((ref) {
      return DriftHousekeeperCatalogRepository(ref.watch(appDatabaseProvider));
    });

final housekeeperCatalogProvider = StreamProvider<List<Housekeeper>>((
  ref,
) async* {
  final repository = ref.watch(housekeeperCatalogRepositoryProvider);
  await repository.ensureDefaults(ref.watch(clockProvider).now());
  yield* repository.watchActive();
});

final housekeeperCatalogByIdProvider = Provider<Map<String, Housekeeper>>((
  ref,
) {
  final values = ref.watch(housekeeperCatalogProvider).value;
  if (values == null) return const {};
  return Map.unmodifiable({for (final value in values) value.id: value});
});

final housekeeperCatalogControllerProvider =
    NotifierProvider<
      HousekeeperCatalogController,
      HousekeeperCatalogEditorState
    >(HousekeeperCatalogController.new);

final class HousekeeperCatalogEditorState {
  const HousekeeperCatalogEditorState({
    required this.message,
    this.busy = false,
  });

  static const initialMessage =
      'Имена идут из свежих листов; список можно менять под смену.';

  final String message;
  final bool busy;
}

final class HousekeeperCatalogController
    extends Notifier<HousekeeperCatalogEditorState> {
  var _sequence = 0;
  Future<void> _tail = Future<void>.value();

  @override
  HousekeeperCatalogEditorState build() {
    return const HousekeeperCatalogEditorState(
      message: HousekeeperCatalogEditorState.initialMessage,
    );
  }

  Future<HousekeeperCatalogMutation> add(String displayName) {
    final trimmed = displayName.trim();
    return _execute(
      AddHousekeeperCommand(
        commandId: _commandId(),
        issuedAt: _issuedAt(),
        displayName: displayName,
      ),
      successMessage: trimmed.isEmpty ? null : '$trimmed добавлена.',
      ignoredMessage: trimmed.isEmpty
          ? 'Напиши имя перед добавлением.'
          : 'Такое имя уже есть.',
    );
  }

  Future<HousekeeperCatalogMutation> rename({
    required String housekeeperId,
    required String displayName,
  }) {
    final trimmed = displayName.trim();
    return _execute(
      RenameHousekeeperCommand(
        commandId: _commandId(),
        issuedAt: _issuedAt(),
        housekeeperId: housekeeperId,
        displayName: displayName,
      ),
      successMessage: '$trimmed сохранена.',
      ignoredMessage: trimmed.isEmpty
          ? 'Имя не может быть пустым.'
          : 'Имя не изменилось или уже занято.',
    );
  }

  Future<HousekeeperCatalogMutation> setPalette({
    required String housekeeperId,
    required String paletteKey,
  }) {
    return _execute(
      SetHousekeeperPaletteCommand(
        commandId: _commandId(),
        issuedAt: _issuedAt(),
        housekeeperId: housekeeperId,
        paletteKey: paletteKey,
      ),
      successMessage: 'Цвет сохранён.',
      ignoredMessage: 'Цвет не изменился.',
    );
  }

  Future<HousekeeperCatalogMutation> _execute(
    HousekeeperCatalogCommand command, {
    required String? successMessage,
    required String ignoredMessage,
  }) {
    final completer = Completer<HousekeeperCatalogMutation>();
    _tail = _tail.then((_) async {
      state = HousekeeperCatalogEditorState(message: state.message, busy: true);
      try {
        final result = await HousekeeperCatalogCommandHandler(
          ref.read(housekeeperCatalogRepositoryProvider),
        ).execute(command);
        state = HousekeeperCatalogEditorState(
          message: result.status == HousekeeperCatalogMutationStatus.changed
              ? successMessage ?? ignoredMessage
              : ignoredMessage,
        );
        completer.complete(result);
      } catch (error, stackTrace) {
        state = const HousekeeperCatalogEditorState(
          message: 'Не удалось сохранить изменение.',
        );
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  DateTime _issuedAt() {
    _sequence++;
    return ref.read(clockProvider).now().add(Duration(microseconds: _sequence));
  }

  String _commandId() {
    return 'catalog-${ref.read(clockProvider).now().microsecondsSinceEpoch}-'
        '${_sequence + 1}';
  }
}
