import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../interaction/application/margaritaville_interaction_dispatcher.dart';
import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../summary_header_interaction_policy.dart';

final class SummarySelectionPuzzleHandle extends StatefulWidget {
  const SummarySelectionPuzzleHandle({
    required this.onComplete,
    this.onProgressChanged,
    super.key,
  });

  final VoidCallback onComplete;
  final ValueChanged<double>? onProgressChanged;

  @override
  State<SummarySelectionPuzzleHandle> createState() =>
      _SummarySelectionPuzzleHandleState();
}

final class _SummarySelectionPuzzleHandleState
    extends State<SummarySelectionPuzzleHandle> {
  var _drag = 0.0;
  var _armed = false;
  var _committed = false;
  var _feedbackStarted = false;
  var _commitSent = false;
  int? _activePointer;
  Offset? _origin;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        MargaritavilleInteractionDispatcher feedback() =>
            MargaritavilleFeedbackScope.dispatcherOf(context);
        final targetX =
            SummaryHeaderInteractionPolicy.horizontalPadding +
            SummaryHeaderInteractionPolicy.settingsButtonSize / 2;
        final startX =
            constraints.maxWidth -
            SummaryHeaderInteractionPolicy.horizontalPadding -
            SummaryHeaderInteractionPolicy.puzzleStartZoneWidth / 2;
        final travel = (startX - targetX).clamp(1.0, double.infinity);
        final progress = (_drag / travel).clamp(0.0, 1.0);
        final pieceX = startX + (targetX - startX) * progress;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (progress > 0.001)
              Positioned(
                left: targetX - 17,
                top: 7,
                child: _PuzzleGlyph(
                  icon: Icons.extension_off_rounded,
                  progress: progress,
                  isSocket: true,
                ),
              ),
            Positioned(
              left:
                  startX -
                  SummaryHeaderInteractionPolicy.puzzleStartZoneWidth / 2,
              top: 3,
              width: SummaryHeaderInteractionPolicy.puzzleStartZoneWidth,
              height: 42,
              child: Opacity(
                opacity: 1 - (progress * 1.15).clamp(0.0, 0.82),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.08 + 0.07 * progress,
                    ),
                    border: Border.all(
                      color: MargaritavilleColors.accent.withValues(
                        alpha: 0.12 + 0.26 * progress,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            Positioned(
              left: pieceX - 16.5,
              top: 7.5,
              child: _PuzzleGlyph(
                icon: Icons.extension_rounded,
                progress: progress,
              ),
            ),
            Positioned(
              left:
                  startX -
                  (SummaryHeaderInteractionPolicy.puzzleStartZoneWidth + 18) /
                      2,
              top: 0,
              width: SummaryHeaderInteractionPolicy.puzzleStartZoneWidth + 18,
              bottom: 0,
              child: Semantics(
                button: true,
                label: 'Открыть выбор комнат',
                hint: 'Проведите справа налево',
                child: Listener(
                  key: const Key('unlock-workday'),
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _begin,
                  onPointerMove: (event) =>
                      _update(event, travel: travel, feedback: feedback),
                  onPointerUp: (event) => _end(event, travel: travel),
                  onPointerCancel: _cancel,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _begin(PointerDownEvent event) {
    if (_activePointer != null || _committed) return;
    _activePointer = event.pointer;
    _origin = event.position;
  }

  void _update(
    PointerMoveEvent event, {
    required double travel,
    required MargaritavilleInteractionDispatcher Function() feedback,
  }) {
    if (event.pointer != _activePointer || _committed) return;
    final origin = _origin;
    if (origin == null) return;
    final next = (origin.dx - event.position.dx).clamp(
      0.0,
      travel * SummaryHeaderInteractionPolicy.puzzleMaximumProgress,
    );
    if (next <= 0 && _drag <= 0) return;
    if (next > SummaryHeaderInteractionPolicy.puzzleStartFeedbackDistance &&
        !_feedbackStarted) {
      _feedbackStarted = true;
      feedback().signal(MargaritavilleInteractionIntent.holdStart);
    }
    final nextArmed = next >= travel;
    if (nextArmed && !_armed && !_commitSent) {
      _commitSent = true;
      feedback().signal(MargaritavilleInteractionIntent.holdCommit);
    } else if (!nextArmed &&
        next > travel * SummaryHeaderInteractionPolicy.puzzleWarningProgress &&
        _drag <=
            travel * SummaryHeaderInteractionPolicy.puzzleWarningProgress) {
      feedback().signal(MargaritavilleInteractionIntent.holdWarning);
    }
    final progress = (next / travel).clamp(0.0, 1.0);
    setState(() {
      _drag = next;
      _armed = nextArmed;
    });
    widget.onProgressChanged?.call(progress);
  }

  void _end(PointerUpEvent event, {required double travel}) {
    if (event.pointer != _activePointer || _committed) return;
    _activePointer = null;
    _origin = null;
    if (!_armed) {
      _reset();
      return;
    }
    setState(() {
      _committed = true;
      _drag = travel;
    });
    widget.onProgressChanged?.call(1);
    widget.onComplete();
    _resetTimer?.cancel();
    _resetTimer = Timer(SummaryHeaderInteractionPolicy.puzzleResetDelay, () {
      if (mounted) _reset(clearCommitted: true);
    });
  }

  void _cancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    _origin = null;
    _reset();
  }

  void _reset({bool clearCommitted = false}) {
    if (!mounted) return;
    setState(() {
      _drag = 0;
      _armed = false;
      _feedbackStarted = false;
      _commitSent = false;
      if (clearCommitted) {
        _committed = false;
      }
    });
    widget.onProgressChanged?.call(0);
  }
}

final class _PuzzleGlyph extends StatelessWidget {
  const _PuzzleGlyph({
    required this.icon,
    required this.progress,
    this.isSocket = false,
  });

  final IconData icon;
  final double progress;
  final bool isSocket;

  @override
  Widget build(BuildContext context) {
    final color = isSocket
        ? Colors.black.withValues(alpha: 0.32 + 0.22 * progress)
        : MargaritavilleColors.accent.withValues(alpha: 0.48 + 0.48 * progress);
    final dimension = isSocket ? 34.0 : 33.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSocket
            ? Colors.black.withValues(alpha: 0.18 + 0.28 * progress)
            : MargaritavilleColors.accent.withValues(
                alpha: 0.08 + 0.16 * progress,
              ),
        border: Border.all(
          color: MargaritavilleColors.accent.withValues(
            alpha:
                (isSocket ? 0.12 : 0.22) + (isSocket ? 0.28 : 0.34) * progress,
          ),
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSocket
            ? const [
                BoxShadow(
                  color: Color(0x1AFFFFFF),
                  blurRadius: 2,
                  offset: Offset(-1, -1),
                ),
                BoxShadow(
                  color: Color(0x6B000000),
                  blurRadius: 10,
                  offset: Offset(2, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: MargaritavilleColors.accent.withValues(
                    alpha: 0.28 * progress,
                  ),
                  blurRadius: 16,
                ),
              ],
      ),
      child: SizedBox.square(
        dimension: dimension,
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
