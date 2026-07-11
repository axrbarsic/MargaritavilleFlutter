import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/appearance_summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/appearance_settings.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/summary_grid_preference.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';

void main() {
  test('maps persisted appearance settings into the Summary adapter', () {
    const settings = AppearanceSettings(
      liveCellsEnabled: true,
      cellSpringIntensity: 0.48,
      vipJellyEnabled: false,
      vipJellySpeed: 1.25,
      vipHdrLightEnabled: true,
      statusHdrPulseEnabled: true,
      vividStatusPaletteEnabled: false,
      summaryGridPreference: SummaryGridPreference.three,
    );

    final policy = AppearanceSummaryVisualPolicy.fromSettings(settings);

    expect(policy.liveCellsEnabled, isTrue);
    expect(policy.springIntensity, 0.48);
    expect(policy.vipJellyEnabled, isFalse);
    expect(policy.vipJellySpeed, 1.25);
    expect(policy.vipHdrLightEnabled, isTrue);
    expect(policy.statusPulseEnabled, isTrue);
    expect(policy.vividStatusPaletteEnabled, isFalse);
    expect(policy.transientPulseEnabled, isTrue);
    expect(policy.gridColumns, SummaryGridColumns.three);
  });
}
