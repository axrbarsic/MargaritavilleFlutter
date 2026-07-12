import 'dart:async';

import 'package:flutter/material.dart';

import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../domain/models/room_cell_typography_profile.dart';

final class RoomCellCalibrationControls extends StatelessWidget {
  const RoomCellCalibrationControls({
    required this.layout,
    required this.role,
    required this.profile,
    required this.platform,
    required this.onLayoutChanged,
    required this.onRoleChanged,
    required this.onApply,
    required this.onSave,
    required this.onReset,
    required this.onCopy,
    super.key,
  });

  final RoomCellLayoutProfile layout;
  final RoomCellTypographyRole role;
  final RoomCellTypographyProfile profile;
  final RoomCellCalibrationPlatform platform;
  final ValueChanged<RoomCellLayoutProfile> onLayoutChanged;
  final ValueChanged<RoomCellTypographyRole> onRoleChanged;
  final VoidCallback onApply;
  final Future<void> Function() onSave;
  final VoidCallback onReset;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF14231D),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${platform == RoomCellCalibrationPlatform.ios ? 'iOS' : 'Android'} · '
                    '${layout.columns} колонки',
                    key: const Key('cell-calibration-active-profile'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SegmentedButton<RoomCellLayoutProfile>(
                  key: const Key('cell-calibration-layout-selector'),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: RoomCellLayoutProfile.three,
                      label: Text('3'),
                    ),
                    ButtonSegment(
                      value: RoomCellLayoutProfile.four,
                      label: Text('4'),
                    ),
                  ],
                  selected: {layout},
                  onSelectionChanged: (values) =>
                      onLayoutChanged(values.single),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Номер ${_value(profile.roomNumberSize)} pt '
              '[${_value(RoomCellTypographyProfile.roomNumberMin)}–'
              '${_value(RoomCellTypographyProfile.roomNumberMax)}]  ·  '
              'Время ${_value(profile.roomTimeSize)} pt '
              '[${_value(RoomCellTypographyProfile.roomTimeMin)}–'
              '${_value(RoomCellTypographyProfile.roomTimeMax)}]',
              key: const Key('cell-calibration-values'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<RoomCellTypographyRole>(
                key: const Key('cell-calibration-role-selector'),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: RoomCellTypographyRole.roomNumber,
                    label: Text('Номер'),
                  ),
                  ButtonSegment(
                    value: RoomCellTypographyRole.roomTime,
                    label: Text('Время'),
                  ),
                  ButtonSegment(
                    value: RoomCellTypographyRole.proportional,
                    label: Text('Все'),
                  ),
                ],
                selected: {role},
                onSelectionChanged: (values) => onRoleChanged(values.single),
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const Key('cell-calibration-apply'),
                  onPressed: onApply,
                  child: const Text('Применить'),
                ),
                FilledButton.tonal(
                  key: const Key('cell-calibration-save'),
                  onPressed: () => unawaited(
                    MargaritavilleFeedbackScope.dispatcherOf(
                      context,
                    ).acceptAsyncOnce(
                      'cell-calibration-save-${platform.name}-${layout.columns}',
                      MargaritavilleInteractionIntent.confirm,
                      onSave,
                    ),
                  ),
                  child: const Text('Зафиксировать'),
                ),
                OutlinedButton(
                  key: const Key('cell-calibration-reset'),
                  onPressed: onReset,
                  child: const Text('Сбросить'),
                ),
                OutlinedButton.icon(
                  key: const Key('cell-calibration-copy'),
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Скопировать значения'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _value(double value) => value.toStringAsFixed(1);
}
