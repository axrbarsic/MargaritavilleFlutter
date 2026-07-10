import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';

final class SummarySelectionPuzzleHandle extends StatefulWidget {
  const SummarySelectionPuzzleHandle({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<SummarySelectionPuzzleHandle> createState() =>
      _SummarySelectionPuzzleHandleState();
}

final class _SummarySelectionPuzzleHandleState
    extends State<SummarySelectionPuzzleHandle> {
  static const _horizontalPadding = 18.0;
  static const _settingsButtonSize = 48.0;
  static const _startZoneWidth = 86.0;

  var _drag = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetX = _horizontalPadding + _settingsButtonSize / 2;
        final startX =
            constraints.maxWidth - _horizontalPadding - _startZoneWidth / 2;
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
              left: startX - _startZoneWidth / 2,
              top: 3,
              width: _startZoneWidth,
              height: 42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08 + 0.07 * progress),
                  border: Border.all(
                    color: MargaritavilleColors.accent.withValues(
                      alpha: 0.12 + 0.26 * progress,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(18),
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
              left: startX - (_startZoneWidth + 18) / 2,
              top: 0,
              width: _startZoneWidth + 18,
              bottom: 0,
              child: Semantics(
                button: true,
                label: 'Открыть выбор комнат',
                hint: 'Проведите справа налево',
                child: GestureDetector(
                  key: const Key('unlock-workday'),
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _drag = (_drag - details.delta.dx).clamp(
                        0.0,
                        travel * 1.08,
                      );
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_drag >= travel) widget.onComplete();
                    setState(() => _drag = 0);
                  },
                  onHorizontalDragCancel: () => setState(() => _drag = 0),
                ),
              ),
            ),
          ],
        );
      },
    );
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSocket
            ? Colors.black.withValues(alpha: 0.18 + 0.28 * progress)
            : MargaritavilleColors.accent.withValues(
                alpha: 0.08 + 0.16 * progress,
              ),
        border: Border.all(
          color: MargaritavilleColors.accent.withValues(
            alpha: 0.12 + 0.34 * progress,
          ),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox.square(
        dimension: 33,
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
