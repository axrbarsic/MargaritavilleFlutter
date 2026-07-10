import '../../design/margaritaville_colors.dart';
import '../../features/summary/presentation/summary_layout_tokens.dart';
import '../../features/summary/presentation/summary_visual_policy.dart';
import '../../features/summary/presentation/summary_visual_pulse.dart';
import '../../features/work_session/domain/models/room_state.dart';
import 'generated/edr_overlay_api.g.dart';

abstract final class EdrTileSnapshotFactory {
  static EdrTileSnapshot create({
    required RoomState room,
    required SummaryVisualPolicy policy,
    required double left,
    required double width,
    SummaryVisualPulseEvent? pulseEvent,
  }) {
    final baseColor = policy.vividStatusPaletteEnabled
        ? MargaritavilleColors.vividStatus(room.displayStatus)
        : MargaritavilleColors.status(room.displayStatus);
    final pulse = policy.transientPulseEnabled ? pulseEvent : null;
    final pulseColor = pulse == null
        ? null
        : policy.vividStatusPaletteEnabled
        ? MargaritavilleColors.vividStatus(pulse.status)
        : MargaritavilleColors.status(pulse.status);
    return EdrTileSnapshot(
      roomId: room.roomNumber,
      timeText: '',
      left: left,
      top: 0,
      width: width,
      height: SummaryLayoutTokens.tileHeight,
      baseColorArgb: baseColor.toARGB32(),
      cornerRadius: SummaryLayoutTokens.tileCornerRadius,
      vipHdrEnabled: room.isVip && policy.vipHdrLightEnabled,
      vipJellyEnabled: room.isVip && policy.vipJellyEnabled,
      vipJellySpeed: policy.vipJellySpeed,
      pulseGeneration: pulse?.generation,
      pulseColorArgb: policy.statusPulseEnabled ? pulseColor?.toARGB32() : null,
      pulseBoostColorArgb: policy.statusPulseEnabled && pulse != null
          ? MargaritavilleColors.vividStatus(pulse.status).toARGB32()
          : null,
      pulseStartedAtMicros: pulse?.startedAt.microsecondsSinceEpoch,
      springIntensity: policy.springIntensity,
    );
  }
}
