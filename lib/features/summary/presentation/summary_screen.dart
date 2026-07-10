import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../work_session/domain/models/room_state.dart';
import '../../work_session/domain/models/work_session.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import 'summary_layout_tokens.dart';
import 'widgets/room_schedule_sheet.dart';
import 'widgets/summary_assignment_section.dart';
import 'widgets/summary_header.dart';

final class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({
    required this.session,
    this.enableSchedulePolling = false,
    super.key,
  });

  final WorkSession session;
  final bool enableSchedulePolling;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

final class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with WidgetsBindingObserver {
  RoomDisplayStatus? _activeFilter;
  Timer? _scheduleTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.enableSchedulePolling) return;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _advanceScheduledRooms();
    });
    _scheduleTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _advanceScheduledRooms();
    });
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enableSchedulePolling && state == AppLifecycleState.resumed) {
      _advanceScheduledRooms();
    }
  }

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
                      onToggleVip: _toggleVip,
                      onSchedule: _openSchedule,
                      onOpenMedia: _showMediaNotice,
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

  void _toggleVip(RoomState room) {
    unawaited(
      ref
          .read(workSessionControllerProvider.notifier)
          .setRoomVip(room.roomNumber, isVip: !room.isVip),
    );
  }

  void _openSchedule(RoomState room) {
    unawaited(
      showRoomScheduleSheet(
        context: context,
        room: room,
        now: ref.read(clockProvider).now(),
        onSet: (date) {
          unawaited(
            ref
                .read(workSessionControllerProvider.notifier)
                .setRoomSchedule(room.roomNumber, scheduledFor: date),
          );
        },
        onClear: () {
          unawaited(
            ref
                .read(workSessionControllerProvider.notifier)
                .setRoomSchedule(room.roomNumber, scheduledFor: null),
          );
        },
      ),
    );
  }

  void _advanceScheduledRooms() {
    if (!mounted) return;
    final state = ref.read(workSessionControllerProvider);
    if (!state.hasValue || state.requireValue.id != widget.session.id) return;
    unawaited(
      ref.read(workSessionControllerProvider.notifier).advanceScheduledRooms(),
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

  void _showMediaNotice(RoomState room) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Голос и медиа комнаты ${room.roomNumber} — следующий platform-services блок.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
