import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_minimum_scale_text.dart';

void main() {
  testWidgets('minimum scale responds to width and never to a short box', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 88,
            height: 8,
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
    expect(rendered.style?.fontSize, closeTo(44 * (88 / 132), 0.01));
    expect(rendered.style!.fontSize, greaterThan(22));
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
