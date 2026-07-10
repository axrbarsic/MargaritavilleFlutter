import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/appearance_settings.dart';

void main() {
  test('visual settings use the active Swift build 37 defaults', () {
    const settings = AppearanceSettings.defaults;

    expect(settings.liveCellsEnabled, isFalse);
    expect(settings.cellSpringIntensity, 0.72);
    expect(settings.vipJellyEnabled, isTrue);
    expect(settings.vipJellySpeed, 0.75);
    expect(settings.vipHdrLightEnabled, isFalse);
    expect(settings.statusHdrPulseEnabled, isFalse);
  });

  test('visual settings clamp donor-controlled ranges', () {
    final normalized = AppearanceSettings.defaults
        .copyWith(cellSpringIntensity: 2, vipJellySpeed: 0.05)
        .normalized();

    expect(normalized.cellSpringIntensity, 1);
    expect(normalized.vipJellySpeed, 0.2);
  });
}
