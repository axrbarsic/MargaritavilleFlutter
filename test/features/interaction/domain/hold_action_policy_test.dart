import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/interaction/domain/hold_action_policy.dart';

void main() {
  test('locks the donor build 37 hold timing and movement contract', () {
    expect(
      HoldActionPolicy.donor.holdStartDelay,
      const Duration(milliseconds: 140),
    );
    expect(
      HoldActionPolicy.donor.holdWarningDelay,
      const Duration(milliseconds: 330),
    );
    expect(
      HoldActionPolicy.donor.commitDelay,
      const Duration(milliseconds: 460),
    );
    expect(HoldActionPolicy.donor.maximumMovement, 8);
  });
}
