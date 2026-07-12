import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/edr/edr_overlay_controller.dart';
import '../../../shared/edr/edr_overlay_scope.dart';
import '../../../shared/edr/edr_window_surface.dart';
import '../../cell_calibration/domain/models/room_cell_typography_profile.dart';
import '../../housekeeper_catalog/domain/models/housekeeper.dart';
import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../room_details/presentation/room_details_screen.dart';
import '../../work_session/domain/models/room_state.dart';
import '../../work_session/domain/models/work_assignment.dart';
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
    this.scrollController,
    this.edrController,
    this.housekeeperCatalogById = const {},
    this.typographyProfile = RoomCellTypographyProfile.defaults,
    super.key,
  });

  final WorkSession session;
  final bool enableSchedulePolling;
  final SummaryVisualPolicy visualPolicy;
  final Future<void> Function()? onOpenSettings;
  final ScrollController? scrollController;
  final EdrOverlayController? edrController;
  final Map<String, Housekeeper> housekeeperCatalogById;
  final RoomCellTypographyProfile typographyProfile;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

final class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with WidgetsBindingObserver {
  RoomDisplayStatus? _activeFilter;
  Timer? _scheduleTimer;
  late final SummaryVisualPulseCoordinator _visualPulses;
  late final EdrOverlayController _edrWindow;
  late final bool _ownsEdrController;
  late final ScrollController _scrollController;
  late final bool _ownsScrollController;
  (double, double, double, AxisDirection)? _lastEdrLayoutMetrics;
  var _settingsPresentationInFlight = false;

  @override
  void initState() {
    super.initState();
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_synchronizeEdrScrollOffset);
    _visualPulses = SummaryVisualPulseCoordinator()
      ..addListener(_onVisualEventsChanged);
    _ownsEdrController = widget.edrController == null;
    _edrWindow = widget.edrController ?? EdrOverlayController();
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
  void didUpdateWidget(covariant SummaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualPolicy.gridColumns == widget.visualPolicy.gridColumns) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _edrWindow.requestGeometrySync();
    });
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _visualPulses
      ..removeListener(_onVisualEventsChanged)
      ..dispose();
    if (_ownsEdrController) _edrWindow.dispose();
    _scrollController.removeListener(_synchronizeEdrScrollOffset);
    if (_ownsScrollController) _scrollController.dispose();
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
    final sections = _summarySections(widget.session, _activeFilter);
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
                onOpenSettings: widget.onOpenSettings == null
                    ? () => _showSettingsNotice(context)
                    : () => unawaited(_openSettingsOnce()),
                onOpenSelection: _unlockWorkday,
              ),
              const SizedBox(height: SummaryLayoutTokens.headerContentGap),
              Expanded(
                child: EdrViewportScope(
                  controller: _edrWindow,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_nativeEdrRequested && EdrWindowSurface.supported)
                        EdrWindowSurface(controller: _edrWindow),
                      NotificationListener<ScrollMetricsNotification>(
                        onNotification: _synchronizeEdrViewport,
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            SummaryLayoutTokens.contentHorizontalPadding,
                            0,
                            SummaryLayoutTokens.contentHorizontalPadding,
                            SummaryLayoutTokens.contentBottomPadding,
                          ),
                          children: [
                            Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < sections.length;
                                  index++
                                ) ...[
                                  if (index > 0)
                                    const SizedBox(
                                      height:
                                          SummaryLayoutTokens.sectionSpacing,
                                    ),
                                  _edrSection(
                                    sections[index],
                                    widget.housekeeperCatalogById,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Future<void> _openSettingsOnce() async {
    final openSettings = widget.onOpenSettings;
    if (openSettings == null || _settingsPresentationInFlight) return;
    _settingsPresentationInFlight = true;
    try {
      MargaritavilleFeedbackScope.dispatcherOf(
        context,
      ).signal(MargaritavilleInteractionIntent.openSettings);
      try {
        await _withEdrOccluded(openSettings);
      } on StateError catch (error) {
        debugPrint(
          'Настройки не открыты: native EDR не подтвердил окклюзию: $error',
        );
      }
    } finally {
      _settingsPresentationInFlight = false;
    }
  }

  bool _synchronizeEdrViewport(ScrollMetricsNotification notification) {
    final metrics = notification.metrics;
    final layoutMetrics = (
      metrics.viewportDimension,
      metrics.minScrollExtent,
      metrics.maxScrollExtent,
      metrics.axisDirection,
    );
    if (_lastEdrLayoutMetrics == layoutMetrics) return false;
    _lastEdrLayoutMetrics = layoutMetrics;
    _edrWindow.requestGeometrySync();
    return false;
  }

  void _synchronizeEdrScrollOffset() {
    if (_scrollController.hasClients) {
      _edrWindow.updateScrollOffset(Offset(0, _scrollController.offset));
    }
  }

  Widget _edrSection(
    ({WorkAssignment assignment, List<RoomState> rooms}) section,
    Map<String, Housekeeper> catalogById,
  ) {
    final assignment = section.assignment;
    return SummaryAssignmentSection(
      assignment: assignment,
      housekeeper: catalogById[assignment.housekeeper.id],
      rooms: section.rooms,
      onAdvance: _advanceRoom,
      onReset: _resetRoom,
      onToggleVip: _toggleVip,
      onSchedule: _openSchedule,
      onOpenMedia: _openMedia,
      visualPolicy: widget.visualPolicy,
      pulseEventFor: _visualPulses.eventFor,
      typographyProfile: widget.typographyProfile,
    );
  }

  bool get _nativeEdrRequested =>
      widget.visualPolicy.vipHdrLightEnabled ||
      widget.visualPolicy.vipJellyEnabled ||
      widget.visualPolicy.statusPulseEnabled;
}

List<({WorkAssignment assignment, List<RoomState> rooms})> _summarySections(
  WorkSession session,
  RoomDisplayStatus? activeFilter,
) {
  final byHousekeeper =
      <String, ({WorkAssignment assignment, List<RoomState> rooms})>{};
  final assignments = session.activeAssignments.toList()
    ..sort((left, right) => left.cartNumber.compareTo(right.cartNumber));
  for (final assignment in assignments) {
    final section = byHousekeeper.putIfAbsent(
      assignment.housekeeper.id,
      () => (assignment: assignment, rooms: <RoomState>[]),
    );
    section.rooms.addAll(
      assignment.activeRooms.where(
        (room) => activeFilter == null || room.displayStatus == activeFilter,
      ),
    );
  }
  return byHousekeeper.values
      .where((section) => section.rooms.isNotEmpty)
      .toList(growable: false);
}
