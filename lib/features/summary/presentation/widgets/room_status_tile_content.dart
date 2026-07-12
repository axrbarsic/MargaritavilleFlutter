import 'package:flutter/material.dart';

import '../../../cell_calibration/domain/models/room_cell_typography_profile.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_typography.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'room_visual_effect_surface.dart';
import 'summary_minimum_scale_text.dart';

final class RoomStatusTileContent extends StatelessWidget {
  const RoomStatusTileContent({
    required this.room,
    required this.color,
    required this.visualPolicy,
    required this.pulseEvent,
    required this.nativeEdrActive,
    required this.nativeEdrManaged,
    required this.contentScale,
    required this.fontScale,
    required this.compressTextVertically,
    required this.timestampText,
    this.typographyProfile = RoomCellTypographyProfile.defaults,
    super.key,
  });

  final RoomState room;
  final Color color;
  final SummaryVisualPolicy visualPolicy;
  final SummaryVisualPulseEvent? pulseEvent;
  final bool nativeEdrActive;
  final bool nativeEdrManaged;
  final double contentScale;
  final double fontScale;
  final bool compressTextVertically;
  final String timestampText;
  final RoomCellTypographyProfile typographyProfile;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: RoomVisualEffectSurface(
        room: room,
        baseColor: color,
        policy: visualPolicy,
        pulseEvent: pulseEvent,
        nativeEdrActive: nativeEdrActive,
        nativeEdrManaged: nativeEdrManaged,
        child: Opacity(
          opacity: nativeEdrActive ? 0 : 1,
          child: DecoratedBox(
            key: Key('summary-room-surface-${room.roomNumber}'),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                SummaryLayoutTokens.tileCornerRadius,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 10 * contentScale,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SummaryMinimumScaleText(
                      key: Key('summary-room-number-text-${room.roomNumber}'),
                      text: room.roomNumber,
                      style: SummaryTypography.roomNumberAtScale(
                        fontScale,
                        profile: typographyProfile,
                      ),
                      minimumScaleFactor: 0.50,
                      compressHeightOnly: compressTextVertically,
                    ),
                  ),
                  SizedBox(height: 6 * contentScale),
                  SummaryMinimumScaleText(
                    key: Key('summary-room-time-text-${room.roomNumber}'),
                    text: timestampText,
                    style: SummaryTypography.roomTimeAtScale(
                      fontScale,
                      profile: typographyProfile,
                    ),
                    minimumScaleFactor: 0.62,
                    compressHeightOnly: compressTextVertically,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
