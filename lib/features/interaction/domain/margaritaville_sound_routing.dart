import 'package:interaction_foundation/interaction_foundation.dart';

enum MargaritavilleSoundAsset {
  none('none', null, 'Без звука'),
  uiClickBright(
    'uiClickBright',
    'assets/sounds/xhotel_ui_click_bright.wav',
    'Яркий клик',
  ),
  uiClickSoft(
    'uiClickSoft',
    'assets/sounds/xhotel_ui_click_soft.wav',
    'Мягкий клик',
  ),
  uiRolloverTick(
    'uiRolloverTick',
    'assets/sounds/xhotel_ui_rollover_tick.wav',
    'Короткий тик',
  ),
  uiSwitchLight(
    'uiSwitchLight',
    'assets/sounds/xhotel_ui_switch_light.wav',
    'Лёгкий переключатель',
  ),
  uiSwitchDeep(
    'uiSwitchDeep',
    'assets/sounds/xhotel_ui_switch_deep.wav',
    'Глубокий переключатель',
  ),
  uiConfirmPop(
    'uiConfirmPop',
    'assets/sounds/xhotel_ui_confirm_pop.wav',
    'Сочный поп',
  ),
  uiConfirmGlass(
    'uiConfirmGlass',
    'assets/sounds/xhotel_ui_confirm_glass.wav',
    'Стеклянное подтверждение',
  ),
  kenneyConfirmation3(
    'kenneyConfirmation3',
    'assets/sounds/kenney_confirmation_003.wav',
    'Плотное подтверждение',
  ),
  uiAlertSnap(
    'uiAlertSnap',
    'assets/sounds/xhotel_ui_alert_snap.wav',
    'Резкий сигнал',
  ),
  uiErrorLow(
    'uiErrorLow',
    'assets/sounds/xhotel_ui_error_low.wav',
    'Низкий отказ',
  ),
  uiMenuOpen(
    'uiMenuOpen',
    'assets/sounds/xhotel_ui_menu_open.wav',
    'Открытие меню',
  ),
  kenneyBong1(
    'kenneyBong1',
    'assets/sounds/kenney_bong_001.wav',
    'Низкий бонг',
  ),
  frontDeskBell(
    'frontDeskBell',
    'assets/sounds/front_desk_bell_real.wav',
    'Звонок стойки',
  );

  const MargaritavilleSoundAsset(this.id, this.packageAssetPath, this.title);

  final String id;
  final String? packageAssetPath;
  final String title;

  static MargaritavilleSoundAsset? fromId(String? id) {
    for (final asset in values) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  static List<InteractionSoundRegistration> get nativeRegistrations => [
    for (final asset in values)
      if (asset.packageAssetPath case final path?)
        InteractionSoundRegistration(id: asset.id, packageAssetPath: path),
  ];
}

enum MargaritavilleSoundSlot {
  interfaceActions(
    'interface_actions',
    'Все остальные действия',
    'Любые действия, которые не касаются ячеек.',
    MargaritavilleSoundAsset.uiRolloverTick,
  ),
  room(
    'room',
    'Ячейка',
    'Любое взаимодействие с ячейкой, кроме финального зелёного статуса.',
    MargaritavilleSoundAsset.uiConfirmGlass,
  ),
  roomReady(
    'room_ready',
    'Зелёная ячейка',
    'Когда ячейка становится зелёной.',
    MargaritavilleSoundAsset.frontDeskBell,
  );

  const MargaritavilleSoundSlot(
    this.id,
    this.title,
    this.subtitle,
    this.defaultAsset,
  );

  final String id;
  final String title;
  final String subtitle;
  final MargaritavilleSoundAsset defaultAsset;
}

enum MargaritavilleSoundEvent {
  tap(20),
  confirm(40),
  longPress(50),
  holdStart(20),
  holdWarning(50),
  holdCommit(60),
  select(40),
  deselect(40),
  invalid(40),
  detent(40),
  settingsOpen(70),
  selectionOpen(70),
  actionMenuOpen(70),
  roomPending(80),
  roomOpen(80),
  roomInProgress(80),
  roomReady(80),
  roomScheduled(80);

  const MargaritavilleSoundEvent(this.priority);

  final int priority;

  MargaritavilleSoundSlot get slot => switch (this) {
    MargaritavilleSoundEvent.roomReady => MargaritavilleSoundSlot.roomReady,
    MargaritavilleSoundEvent.actionMenuOpen ||
    MargaritavilleSoundEvent.roomPending ||
    MargaritavilleSoundEvent.roomOpen ||
    MargaritavilleSoundEvent.roomInProgress ||
    MargaritavilleSoundEvent.roomScheduled => MargaritavilleSoundSlot.room,
    _ => MargaritavilleSoundSlot.interfaceActions,
  };
}

final class MargaritavilleSoundAssignments {
  const MargaritavilleSoundAssignments({
    required this.interfaceActions,
    required this.room,
    required this.roomReady,
  });

  static const defaults = MargaritavilleSoundAssignments(
    interfaceActions: MargaritavilleSoundAsset.uiRolloverTick,
    room: MargaritavilleSoundAsset.uiConfirmGlass,
    roomReady: MargaritavilleSoundAsset.frontDeskBell,
  );

  final MargaritavilleSoundAsset interfaceActions;
  final MargaritavilleSoundAsset room;
  final MargaritavilleSoundAsset roomReady;

  MargaritavilleSoundAsset assetFor(MargaritavilleSoundEvent event) {
    return assetForSlot(event.slot);
  }

  MargaritavilleSoundAsset assetForSlot(MargaritavilleSoundSlot slot) {
    return switch (slot) {
      MargaritavilleSoundSlot.interfaceActions => interfaceActions,
      MargaritavilleSoundSlot.room => room,
      MargaritavilleSoundSlot.roomReady => roomReady,
    };
  }

  MargaritavilleSoundAssignments withAsset(
    MargaritavilleSoundSlot slot,
    MargaritavilleSoundAsset asset,
  ) {
    return MargaritavilleSoundAssignments(
      interfaceActions: slot == MargaritavilleSoundSlot.interfaceActions
          ? asset
          : interfaceActions,
      room: slot == MargaritavilleSoundSlot.room ? asset : room,
      roomReady: slot == MargaritavilleSoundSlot.roomReady ? asset : roomReady,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MargaritavilleSoundAssignments &&
        other.interfaceActions == interfaceActions &&
        other.room == room &&
        other.roomReady == roomReady;
  }

  @override
  int get hashCode => Object.hash(interfaceActions, room, roomReady);
}
