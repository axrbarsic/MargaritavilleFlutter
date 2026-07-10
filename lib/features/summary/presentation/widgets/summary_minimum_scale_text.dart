import 'package:flutter/material.dart';

final class SummaryMinimumScaleText extends StatelessWidget {
  const SummaryMinimumScaleText({
    required this.text,
    required this.style,
    required this.minimumScaleFactor,
    this.alignment = Alignment.center,
    this.textAlign = TextAlign.center,
    this.shrinkWrap = false,
    super.key,
  }) : assert(minimumScaleFactor > 0 && minimumScaleFactor <= 1);

  final String text;
  final TextStyle style;
  final double minimumScaleFactor;
  final Alignment alignment;
  final TextAlign textAlign;
  final bool shrinkWrap;

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
        final rawScale = painter.width <= 0
            ? 1.0
            : availableWidth / painter.width;
        final scale = rawScale.clamp(minimumScaleFactor, 1.0).toDouble();
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
            style: style.copyWith(fontSize: baseFontSize * scale),
          ),
        );
      },
    );
  }
}
