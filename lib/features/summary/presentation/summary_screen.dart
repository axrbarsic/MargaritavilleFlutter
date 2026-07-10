import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../work_session/domain/models/room_state.dart';
import '../../work_session/domain/models/work_session.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import 'summary_layout_tokens.dart';
import 'widgets/summary_assignment_section.dart';
import 'widgets/summary_header.dart';

final class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({required this.session, super.key});

  final WorkSession session;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

final class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  RoomDisplayStatus? _activeFilter;

  @override
  Widget build(BuildContext context) {
    final sections = widget.session.activeAssignments
        .map((assignment) {
          final rooms = assignment.activeRooms
              .where(
                (room) =>
                    _activeFilter == null ||
                    room.displayStatus == _activeFilter,
              )
              .toList();
          return (assignment: assignment, rooms: rooms);
        })
        .where((section) => section.rooms.isNotEmpty)
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: SummaryLayoutTokens.screenTopPadding,
          ),
          child: Column(
            children: [
              SummaryHeader(
                session: widget.session,
                activeFilter: _activeFilter,
                onFilterChanged: (status) {
                  setState(() => _activeFilter = status);
                },
                onOpenSettings: () => _showSettingsNotice(context),
                onOpenSelection: _unlockWorkday,
              ),
              const SizedBox(height: SummaryLayoutTokens.headerContentGap),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    SummaryLayoutTokens.contentHorizontalPadding,
                    0,
                    SummaryLayoutTokens.contentHorizontalPadding,
                    SummaryLayoutTokens.contentBottomPadding,
                  ),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(
                    height: SummaryLayoutTokens.sectionSpacing,
                  ),
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return SummaryAssignmentSection(
                      assignment: section.assignment,
                      rooms: section.rooms,
                      onAdvance: _advanceRoom,
                      onReset: _resetRoom,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _advanceRoom(RoomState room) {
    unawaited(
      ref
          .read(workSessionControllerProvider.notifier)
          .advanceRoom(room.roomNumber),
    );
  }

  void _resetRoom(RoomState room) {
    unawaited(
      ref
          .read(workSessionControllerProvider.notifier)
          .resetRoom(room.roomNumber),
    );
  }

  void _unlockWorkday() {
    unawaited(ref.read(workSessionControllerProvider.notifier).unlockWorkday());
  }

  void _showSettingsNotice(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Настройки — следующий parity-блок. Выбор комнат открывается пазлом справа налево.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
  }
}
