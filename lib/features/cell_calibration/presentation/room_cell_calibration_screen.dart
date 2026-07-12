import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/edr/edr_overlay_controller.dart';
import '../../../shared/edr/edr_overlay_scope.dart';
import '../../../shared/edr/edr_window_surface.dart';
import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../summary/presentation/summary_layout_tokens.dart';
import '../../summary/presentation/summary_tile_geometry.dart';
import '../../summary/presentation/summary_visual_policy.dart';
import '../../summary/presentation/widgets/room_status_tile.dart';
import '../../work_session/domain/models/room_state.dart';
import '../domain/models/room_cell_typography_profile.dart';
import 'controllers/room_cell_calibration_controller.dart';
import 'room_cell_calibration_fixture.dart';
import 'two_finger_scale_gesture_recognizer.dart';
import 'widgets/room_cell_calibration_controls.dart';
import 'widgets/room_cell_calibration_error.dart';
import 'widgets/room_cell_calibration_header.dart';

final class RoomCellCalibrationScreen extends ConsumerStatefulWidget {
  const RoomCellCalibrationScreen({
    required this.edrController,
    required this.baseVisualPolicy,
    required this.onClose,
    super.key,
  });

  final EdrOverlayController edrController;
  final SummaryVisualPolicy baseVisualPolicy;
  final VoidCallback onClose;

  @override
  ConsumerState<RoomCellCalibrationScreen> createState() =>
      _RoomCellCalibrationScreenState();
}

final class _RoomCellCalibrationScreenState
    extends ConsumerState<RoomCellCalibrationScreen> {
  late final ScrollController _scrollController;
  late final List<RoomState> _rooms;
  var _layout = RoomCellLayoutProfile.four;
  var _role = RoomCellTypographyRole.roomNumber;
  RoomCellTypographyProfile? _gestureOrigin;
  var _clampHapticSent = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_syncScroll);
    _rooms = RoomCellCalibrationFixture.build();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calibration = ref.watch(roomCellCalibrationControllerProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onClose();
      },
      child: calibration.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => RoomCellCalibrationError(
          header: _header(context),
          error: error,
          retryButton: FilledButton.icon(
            onPressed: () =>
                ref.invalidate(roomCellCalibrationControllerProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Повторить'),
          ),
        ),
        data: (state) {
          final profile = state.draftFor(_layout);
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(child: _grid(profile)),
                  RoomCellCalibrationControls(
                    layout: _layout,
                    role: _role,
                    profile: profile,
                    platform: state.platform,
                    onLayoutChanged: _changeLayout,
                    onRoleChanged: (role) => setState(() => _role = role),
                    onApply: () => _apply(context),
                    onSave: () => _save(context),
                    onReset: _reset,
                    onCopy: () => _copy(context, state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) => RoomCellCalibrationHeader(
    backButton: IconButton.filledTonal(
      key: const Key('cell-calibration-close'),
      onPressed: widget.onClose,
      icon: const Icon(Icons.chevron_left_rounded),
    ),
  );

  Widget _grid(RoomCellTypographyProfile profile) {
    final columns = _summaryColumns(_layout);
    final policy = SummaryVisualPolicy(
      liveCellsEnabled: widget.baseVisualPolicy.liveCellsEnabled,
      vipJellyEnabled: true,
      vipHdrLightEnabled: true,
      vividStatusPaletteEnabled:
          widget.baseVisualPolicy.vividStatusPaletteEnabled,
      sdrGlowEnabled: widget.baseVisualPolicy.sdrGlowEnabled,
      vipJellySpeed: widget.baseVisualPolicy.vipJellySpeed,
      springIntensity: widget.baseVisualPolicy.springIntensity,
      gridColumns: columns,
    );
    return EdrViewportScope(
      controller: widget.edrController,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (EdrWindowSurface.supported)
            EdrWindowSurface(controller: widget.edrController),
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              widget.edrController.requestGeometrySync();
              return false;
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sectionWidth =
                    constraints.maxWidth -
                    SummaryLayoutTokens.contentHorizontalPadding * 2;
                final geometry = SummaryTileGeometryResolver.resolve(
                  sectionWidth: sectionWidth,
                  columns: columns,
                  platform: Theme.of(context).platform,
                );
                return ListView(
                  key: const Key('cell-calibration-grid'),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                  children: [
                    Wrap(
                      spacing: SummaryLayoutTokens.gridSpacing,
                      runSpacing: SummaryLayoutTokens.gridSpacing,
                      children: [
                        for (final room in _rooms)
                          SizedBox(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            child: RoomStatusTile(
                              room: room,
                              onAdvance: _noop,
                              onReset: _noop,
                              onToggleVip: _noop,
                              onSchedule: _noop,
                              onOpenMedia: _noop,
                              visualPolicy: policy,
                              contentScale: geometry.contentScale,
                              fontScale: geometry.fontScale,
                              compressTextVertically:
                                  geometry.compressTextVertically,
                              typographyProfile: profile,
                              calibrationGesture: _gesture(),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  RoomCellCalibrationGesture _gesture() => RoomCellCalibrationGesture({
    TwoFingerScaleGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<TwoFingerScaleGestureRecognizer>(
          TwoFingerScaleGestureRecognizer.new,
          (recognizer) => recognizer
            ..onStart = _scaleStart
            ..onUpdate = _scaleUpdate
            ..onEnd = _scaleEnd,
        ),
  });

  void _scaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;
    _gestureOrigin = ref
        .read(roomCellCalibrationControllerProvider)
        .requireValue
        .draftFor(_layout);
    _clampHapticSent = false;
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;
    final origin =
        _gestureOrigin ??
        ref
            .read(roomCellCalibrationControllerProvider)
            .requireValue
            .draftFor(_layout);
    _gestureOrigin ??= origin;
    ref
        .read(roomCellCalibrationControllerProvider.notifier)
        .updateDraft(_layout, origin.scale(_role, details.scale));
    if (!_clampHapticSent && origin.wouldClamp(_role, details.scale)) {
      _clampHapticSent = true;
      MargaritavilleFeedbackScope.dispatcherOf(
        context,
      ).signalHapticOnly(MargaritavilleInteractionIntent.holdCommit);
    }
  }

  void _scaleEnd(ScaleEndDetails _) => _gestureOrigin = null;

  void _changeLayout(RoomCellLayoutProfile value) {
    setState(() => _layout = value);
    widget.edrController.requestGeometrySync();
  }

  void _apply(BuildContext context) {
    ref.read(roomCellCalibrationControllerProvider.notifier).apply(_layout);
    _notice(context, 'Профиль применён к рабочей сетке');
  }

  Future<void> _save(BuildContext context) async {
    await ref
        .read(roomCellCalibrationControllerProvider.notifier)
        .save(_layout);
    if (!context.mounted) return;
    _notice(context, 'Профиль зафиксирован локально');
  }

  void _reset() =>
      ref.read(roomCellCalibrationControllerProvider.notifier).reset(_layout);

  Future<void> _copy(
    BuildContext context,
    RoomCellCalibrationState state,
  ) async {
    final snapshot = RoomCellCalibrationSnapshot(
      platform: state.platform,
      layout: _layout,
      profile: state.draftFor(_layout),
    );
    await Clipboard.setData(ClipboardData(text: snapshot.encode()));
    if (context.mounted) _notice(context, 'Значения скопированы');
  }

  void _notice(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _syncScroll() {
    if (_scrollController.hasClients) {
      widget.edrController.updateScrollOffset(
        Offset(0, _scrollController.offset),
      );
    }
  }

  SummaryGridColumns _summaryColumns(RoomCellLayoutProfile layout) =>
      layout == RoomCellLayoutProfile.three
      ? SummaryGridColumns.three
      : SummaryGridColumns.four;

  static void _noop() {}
}
