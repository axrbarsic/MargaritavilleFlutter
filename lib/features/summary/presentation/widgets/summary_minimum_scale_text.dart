import 'dart:math' as math;

import 'package:flutter/material.dart';

final class SummaryMinimumScaleText extends StatelessWidget {
  const SummaryMinimumScaleText({
    required this.text,
    required this.style,
    required this.minimumScaleFactor,
    this.alignment = Alignment.center,
    this.textAlign = TextAlign.center,
    this.shrinkWrap = false,
    this.compressHeightOnly = false,
    super.key,
  }) : assert(minimumScaleFactor > 0 && minimumScaleFactor <= 1);

  final String text;
  final TextStyle style;
  final double minimumScaleFactor;
  final Alignment alignment;
  final TextAlign textAlign;
  final bool shrinkWrap;
  final bool compressHeightOnly;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseFontSize =
            style.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14;
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: TextScaler.noScaling,
        )..layout();
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : painter.width;
        final widthScale = painter.width <= 0
            ? 1.0
            : availableWidth / painter.width;
        final heightScale = constraints.hasBoundedHeight && painter.height > 0
            ? constraints.maxHeight / painter.height
            : 1.0;
        final fontScale = compressHeightOnly
            ? widthScale
            : math.min(widthScale, heightScale);
        final scale = fontScale.clamp(minimumScaleFactor, 1.0).toDouble();
        final fittedStyle = style.copyWith(fontSize: baseFontSize * scale);
        if (compressHeightOnly && constraints.hasBoundedHeight) {
          final fittedPainter = TextPainter(
            text: TextSpan(text: text, style: fittedStyle),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: TextScaler.noScaling,
          )..layout();
          final verticalScale = fittedPainter.height <= 0
              ? 1.0
              : math
                    .min(1.0, constraints.maxHeight / fittedPainter.height)
                    .toDouble();
          return ClipRect(
            child: SizedBox.expand(
              child: OverflowBox(
                minHeight: fittedPainter.height,
                maxHeight: fittedPainter.height,
                alignment: alignment,
                child: Transform.scale(
                  scaleX: 1,
                  scaleY: verticalScale,
                  alignment: alignment,
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    textAlign: textAlign,
                    textScaler: TextScaler.noScaling,
                    style: fittedStyle,
                  ),
                ),
              ),
            ),
          );
        }
        return Align(
          alignment: alignment,
          widthFactor: shrinkWrap || !constraints.hasBoundedWidth ? 1 : null,
          heightFactor: constraints.hasBoundedHeight ? null : 1,
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            textAlign: textAlign,
            textScaler: TextScaler.noScaling,
            style: fittedStyle,
          ),
        );
      },
    );
  }
}
