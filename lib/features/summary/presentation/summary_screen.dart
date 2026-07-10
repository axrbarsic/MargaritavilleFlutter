import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/edr/edr_overlay_controller.dart';
import '../../../shared/edr/edr_overlay_scope.dart';
import '../../../shared/edr/edr_overlay_surface.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
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
    this.visualPolicy = SummaryVisualPolicy.balanced,
    this.onOpenSettings,
    super.key,
  });

  final WorkSession session;
  final bool enableSchedulePolling;
  final SummaryVisualPolicy visualPolicy;
  final VoidCallback? onOpenSettings;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

final class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with WidgetsBindingObserver {
  RoomDisplayStatus? _activeFilter;
  Timer? _scheduleTimer;
  late final SummaryVisualPulseCoordinator _visualPulses;
  late final EdrOverlayController _edrOverlay;

  @override
  void initState() {
    super.initState();
    _visualPulses = SummaryVisualPulseCoordinator()
      ..addListener(_onVisualEventsChanged);
    _edrOverlay = EdrOverlayController();
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
    _edrOverlay.dispose();
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
                onOpenSettings:
                    widget.onOpenSettings ?? () => _showSettingsNotice(context),
                onOpenSelection: _unlockWorkday,
              ),
              const SizedBox(height: SummaryLayoutTokens.headerContentGap),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    SummaryLayoutTokens.contentHorizontalPadding,
                    0,
                    SummaryLayoutTokens.contentHorizontalPadding,
                    SummaryLayoutTokens.contentBottomPadding,
                  ),
                  child: EdrOverlayScope(
                    controller: _edrOverlay,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: EdrOverlaySurface(controller: _edrOverlay),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (
                              var index = 0;
                              index < sections.length;
                              index++
                            ) ...[
                              if (index > 0)
                                const SizedBox(
                                  height: SummaryLayoutTokens.sectionSpacing,
                                ),
                              SummaryAssignmentSection(
                                assignment: sections[index].assignment,
                                rooms: sections[index].rooms,
                                onAdvance: _advanceRoom,
                                onReset: _resetRoom,
                                onToggleVip: _toggleVip,
                                onSchedule: _openSchedule,
                                onOpenMedia: _showMediaNotice,
                                visualPolicy: widget.visualPolicy,
                                pulseEventFor: _visualPulses.eventFor,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onVisualEventsChanged() {
    if (mounted) setState(() {});
  }
}
