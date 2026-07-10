import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../work_session/domain/models/room_state.dart';
import '../../work_session/domain/models/work_session.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import 'widgets/summary_assignment_section.dart';
import 'widgets/summary_counts.dart';

final class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({required this.session, super.key});

  final WorkSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = session.activeAssignments
        .where((assignment) => assignment.activeRooms.isNotEmpty)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Текущая смена'),
        actions: [
          Tooltip(
            message: 'Удерживайте для редактирования смены',
            child: Semantics(
              button: true,
              label: 'Редактировать смену',
              hint: 'Удерживайте',
              child: GestureDetector(
                key: const Key('unlock-workday'),
                onLongPress: () {
                  unawaited(
                    ref
                        .read(workSessionControllerProvider.notifier)
                        .unlockWorkday(),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Icon(Icons.edit_calendar_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          itemCount: assignments.length + 2,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) return SummaryCountsView(session: session);
            if (index == 1) {
              return Text(
                'Удерживайте номер: жёлтый → красный → зелёный.',
                style: Theme.of(context).textTheme.bodySmall,
              );
            }
            final assignment = assignments[index - 2];
            return SummaryAssignmentSection(
              assignment: assignment,
              onAdvance: (room) => _advanceRoom(ref, room),
              onReset: (room) => _resetRoom(ref, room),
            );
          },
        ),
      ),
    );
  }

  void _advanceRoom(WidgetRef ref, RoomState room) {
    unawaited(
      ref
          .read(workSessionControllerProvider.notifier)
          .advanceRoom(room.roomNumber),
    );
  }

  void _resetRoom(WidgetRef ref, RoomState room) {
    unawaited(
      ref
          .read(workSessionControllerProvider.notifier)
          .resetRoom(room.roomNumber),
    );
  }
}
