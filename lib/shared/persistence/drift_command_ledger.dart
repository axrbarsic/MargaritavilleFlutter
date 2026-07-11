import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import 'app_database.dart';

enum CommandLedgerStatus { applied, duplicate, ignored }

final class CommandLedgerEnvelope {
  factory CommandLedgerEnvelope({
    required String sessionId,
    required String commandId,
    required int commandVersion,
    required String commandType,
    required String commandFingerprint,
    required DateTime issuedAt,
    required String eventId,
    required String eventType,
    required Map<String, Object?> eventPayload,
  }) {
    return CommandLedgerEnvelope._(
      aggregateType: 'work-session',
      aggregateId: sessionId,
      sessionId: sessionId,
      commandId: commandId,
      commandVersion: commandVersion,
      commandType: commandType,
      commandFingerprint: commandFingerprint,
      issuedAt: issuedAt,
      eventId: eventId,
      eventType: eventType,
      eventPayload: Map.unmodifiable(eventPayload),
    );
  }

  factory CommandLedgerEnvelope.forAggregate({
    required String aggregateType,
    required String aggregateId,
    required String commandId,
    required int commandVersion,
    required String commandType,
    required String commandFingerprint,
    required DateTime issuedAt,
    required String eventId,
    required String eventType,
    required Map<String, Object?> eventPayload,
  }) {
    if (aggregateType.trim().isEmpty || aggregateId.trim().isEmpty) {
      throw ArgumentError('Command aggregate scope must not be empty.');
    }
    if (aggregateType == 'work-session') {
      throw ArgumentError(
        'Work-session commands must use the session-scoped constructor.',
      );
    }
    return CommandLedgerEnvelope._(
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      sessionId: null,
      commandId: commandId,
      commandVersion: commandVersion,
      commandType: commandType,
      commandFingerprint: commandFingerprint,
      issuedAt: issuedAt,
      eventId: eventId,
      eventType: eventType,
      eventPayload: Map.unmodifiable(eventPayload),
    );
  }

  const CommandLedgerEnvelope._({
    required this.aggregateType,
    required this.aggregateId,
    required this.sessionId,
    required this.commandId,
    required this.commandVersion,
    required this.commandType,
    required this.commandFingerprint,
    required this.issuedAt,
    required this.eventId,
    required this.eventType,
    required this.eventPayload,
  });

  final String aggregateType;
  final String aggregateId;
  final String? sessionId;
  final String commandId;
  final int commandVersion;
  final String commandType;
  final String commandFingerprint;
  final DateTime issuedAt;
  final String eventId;
  final String eventType;
  final Map<String, Object?> eventPayload;

  static String fingerprint(Map<String, Object?> canonicalPayload) {
    return sha256.convert(utf8.encode(jsonEncode(canonicalPayload))).toString();
  }
}

final class DriftCommandLedger {
  const DriftCommandLedger(this._database);

  final AppDatabase _database;

  Future<CommandLedgerStatus> commit({
    required CommandLedgerEnvelope envelope,
    required Future<bool> Function() mutate,
    Map<String, Object?> Function()? eventPayloadAfterMutation,
    Future<void> Function()? onApplied,
  }) {
    return _database.transaction(() async {
      if (!await _claim(envelope)) return CommandLedgerStatus.duplicate;
      final changed = await mutate();
      if (!changed) {
        await _finish(envelope, CommandLedgerStatus.ignored);
        return CommandLedgerStatus.ignored;
      }
      await _database
          .into(_database.historyEventRecords)
          .insert(
            HistoryEventRecordsCompanion.insert(
              id: envelope.eventId,
              aggregateType: envelope.aggregateType,
              aggregateId: envelope.aggregateId,
              sessionId: Value(envelope.sessionId),
              commandId: envelope.commandId,
              eventType: envelope.eventType,
              eventVersion: Value(envelope.commandVersion),
              payloadJson: jsonEncode(
                eventPayloadAfterMutation?.call() ?? envelope.eventPayload,
              ),
              happenedAt: envelope.issuedAt,
            ),
          );
      await _database
          .into(_database.syncOutboxRecords)
          .insert(
            SyncOutboxRecordsCompanion.insert(
              eventId: envelope.eventId,
              aggregateType: envelope.aggregateType,
              aggregateId: envelope.aggregateId,
              sessionId: Value(envelope.sessionId),
            ),
          );
      await _finish(envelope, CommandLedgerStatus.applied);
      await onApplied?.call();
      return CommandLedgerStatus.applied;
    });
  }

  Future<bool> _claim(CommandLedgerEnvelope envelope) async {
    final inserted = await _database
        .into(_database.commandReceiptRecords)
        .insertReturningOrNull(
          CommandReceiptRecordsCompanion.insert(
            aggregateType: envelope.aggregateType,
            aggregateId: envelope.aggregateId,
            sessionId: Value(envelope.sessionId),
            commandId: envelope.commandId,
            commandVersion: Value(envelope.commandVersion),
            commandType: Value(envelope.commandType),
            commandFingerprint: Value(envelope.commandFingerprint),
            issuedAtMicros: Value(envelope.issuedAt.microsecondsSinceEpoch),
            outcome: 'processing',
            processedAt: envelope.issuedAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (inserted != null) return true;

    final query = _database.select(_database.commandReceiptRecords)
      ..where(
        (row) =>
            row.aggregateType.equals(envelope.aggregateType) &
            row.aggregateId.equals(envelope.aggregateId) &
            row.commandId.equals(envelope.commandId),
      )
      ..limit(1);
    final existing = await query.getSingle();
    final versionMatches = existing.commandVersion == envelope.commandVersion;
    final typeMatches =
        existing.commandType == null ||
        existing.commandType == envelope.commandType;
    final fingerprintMatches =
        existing.commandFingerprint == null ||
        existing.commandFingerprint == envelope.commandFingerprint;
    if (!versionMatches || !typeMatches || !fingerprintMatches) {
      throw StateError(
        'Command ${envelope.commandId} conflicts with its durable receipt.',
      );
    }
    return false;
  }

  Future<void> _finish(
    CommandLedgerEnvelope envelope,
    CommandLedgerStatus status,
  ) {
    final update = _database.update(_database.commandReceiptRecords)
      ..where(
        (row) =>
            row.aggregateType.equals(envelope.aggregateType) &
            row.aggregateId.equals(envelope.aggregateId) &
            row.commandId.equals(envelope.commandId),
      );
    return update.write(
      CommandReceiptRecordsCompanion(
        outcome: Value(status.name),
        processedAt: Value(envelope.issuedAt),
      ),
    );
  }
}
