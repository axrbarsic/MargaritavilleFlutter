import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/visual_runtime/visual_runtime_scope.dart';
import '../../work_session/domain/models/room_state.dart';
import '../../work_session/domain/models/work_session.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import 'summary_layout_tokens.dart';
import 'summary_visual_policy.dart';
import 'summary_visual_pulse.dart';
import 'widgets/room_schedule_sheet.dart';
import 'widgets/summary_assignment_section.dart';
import 'widgets/summary_header.dart';

part 'summary_screen_actions.dart';

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
  final _visualPolicy = SummaryVisualPolicy.balanced;
  late final SummaryVisualPulseCoordinator _visualPulses;

  @override
  void initState() {
    super.initState();
    _visualPulses = SummaryVisualPulseCoordinator()
      ..addListener(_onVisualEventsChanged);
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
    _visualPulses
      ..removeListener(_onVisualEventsChanged)
      ..dispose();
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
    final hasActiveVisuals =
        _visualPulses.hasEvents ||
        widget.session.activeRooms.any((room) => room.isVip);
    return VisualRuntimeScope(
      policy: _visualPolicy.framePolicy,
      enabled: hasActiveVisuals,
      child: Scaffold(
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
                        visualPolicy: _visualPolicy,
                        pulseEventFor: _visualPulses.eventFor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onVisualEventsChanged() {
    if (mounted) setState(() {});
  }
}
