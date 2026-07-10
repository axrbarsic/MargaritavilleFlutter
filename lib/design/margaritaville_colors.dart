import 'package:flutter/material.dart';

import '../features/work_session/domain/models/room_state.dart';

abstract final class MargaritavilleColors {
  static const background = Color(0xFF040805);
  static const surface = Color(0xFF020402);
  static const accent = Color(0xFF1EFF5A);
  static const secondaryText = Color(0xFF9BFFB8);
  static const mutedText = Color(0xFF4BB365);
  static const roomForeground = Color(0xFF050505);

  static const pending = Color(0xFFFFD83D);
  static const open = Color(0xFFFF3B30);
  static const ready = Color(0xFF25D366);
  static const scheduled = Color(0xFFFF4DB8);

  static Color vividStatus(RoomDisplayStatus status) {
    return switch (status) {
      RoomDisplayStatus.pending => const Color(0xFFFFC400),
      RoomDisplayStatus.open => const Color(0xFFFF1208),
      RoomDisplayStatus.ready => const Color(0xFF00E524),
      RoomDisplayStatus.scheduled => const Color(0xFFFF31B8),
    };
  }

  static Color status(RoomDisplayStatus status) {
    return switch (status) {
      RoomDisplayStatus.pending => pending,
      RoomDisplayStatus.open => open,
      RoomDisplayStatus.ready => ready,
      RoomDisplayStatus.scheduled => scheduled,
    };
  }

  static Color housekeeper(String paletteKey) {
    return switch (paletteKey) {
      'aqua' => const Color(0xFF00C7D1),
      'amber' => const Color(0xFFFFAD2E),
      'coral' => const Color(0xFFFF614D),
      'orchid' => const Color(0xFFC75CEB),
      'sky' => const Color(0xFF3894FF),
      'mint' => const Color(0xFF52DB8C),
      'ruby' => const Color(0xFFF02E5C),
      'violet' => const Color(0xFF806BFF),
      'lime' => const Color(0xFFB8EB38),
      'slate' => const Color(0xFF94A8C2),
      _ => accent,
    };
  }
}
