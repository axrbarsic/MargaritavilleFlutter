import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_minimum_scale_text.dart';

void main() {
  testWidgets('minimum scale responds to both bounded width and height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 36,
            child: SummaryMinimumScaleText(
              text: '147',
              style: TextStyle(fontSize: 44),
              minimumScaleFactor: 0.5,
            ),
          ),
        ),
      ),
    );

    final rendered = tester.widget<Text>(find.text('147'));
    expect(rendered.style!.fontSize, lessThan(44));
    expect(rendered.style!.fontSize, greaterThanOrEqualTo(22));
    final painter = TextPainter(
      text: TextSpan(text: '147', style: rendered.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    expect(painter.height, lessThanOrEqualTo(36.01));
  });

  testWidgets('minimum factor is the hard lower bound', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 8,
            child: SummaryMinimumScaleText(
              text: '147',
              style: TextStyle(fontSize: 44),
              minimumScaleFactor: 0.5,
            ),
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('147')).style?.fontSize, 22);
  });
}
