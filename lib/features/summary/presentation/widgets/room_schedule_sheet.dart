import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../../work_session/domain/models/room_schedule_selection.dart';
import '../../../work_session/domain/models/room_state.dart';

Future<void> showRoomScheduleSheet({
  required BuildContext context,
  required RoomState room,
  required DateTime now,
  required ValueChanged<DateTime> onSet,
  required VoidCallback onClear,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: MargaritavilleColors.surface,
    showDragHandle: true,
    builder: (context) =>
        RoomScheduleSheet(room: room, now: now, onSet: onSet, onClear: onClear),
  );
}

final class RoomScheduleSheet extends StatefulWidget {
  const RoomScheduleSheet({
    required this.room,
    required this.now,
    required this.onSet,
    required this.onClear,
    super.key,
  });

  final RoomState room;
  final DateTime now;
  final ValueChanged<DateTime> onSet;
  final VoidCallback onClear;

  @override
  State<RoomScheduleSheet> createState() => _RoomScheduleSheetState();
}

final class _RoomScheduleSheetState extends State<RoomScheduleSheet> {
  late RoomScheduleSelection _selection;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();
    _selection = widget.room.scheduledFor == null
        ? RoomScheduleSelection.defaultSelection(widget.now)
        : RoomScheduleSelection.fromDate(widget.room.scheduledFor!);
    _hourController = FixedExtentScrollController(
      initialItem: RoomScheduleSelection.hours.indexOf(_selection.hour),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: RoomScheduleSelection.minutes.indexOf(_selection.minute),
    );
    _periodController = FixedExtentScrollController(
      initialItem: RoomSchedulePeriod.values.indexOf(_selection.period),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 360,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 16),
              _wheelPanel(),
              const SizedBox(height: 16),
              _actionRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Время открытия',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                'Комната ${widget.room.roomNumber}',
                style: const TextStyle(
                  color: MargaritavilleColors.secondaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MargaritavilleColors.scheduled,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            _selection.displayLabel,
            style: const TextStyle(
              color: MargaritavilleColors.roomForeground,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _wheelPanel() {
    return Container(
      height: 162,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        border: Border.all(
          color: MargaritavilleColors.scheduled.withValues(alpha: 0.42),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _picker(
              controller: _hourController,
              values: RoomScheduleSelection.hours
                  .map((value) => '$value')
                  .toList(),
              onChanged: (index) =>
                  MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                    MargaritavilleInteractionIntent.detent,
                    () => setState(() {
                      _selection = _selection.copyWith(
                        hour: RoomScheduleSelection.hours[index],
                      );
                    }),
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _picker(
              controller: _minuteController,
              values: RoomScheduleSelection.minutes
                  .map((value) => value.toString().padLeft(2, '0'))
                  .toList(),
              onChanged: (index) =>
                  MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                    MargaritavilleInteractionIntent.detent,
                    () => setState(() {
                      _selection = _selection.copyWith(
                        minute: RoomScheduleSelection.minutes[index],
                      );
                    }),
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _picker(
              controller: _periodController,
              values: RoomSchedulePeriod.values
                  .map((period) => period.label)
                  .toList(),
              onChanged: (index) =>
                  MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                    MargaritavilleInteractionIntent.detent,
                    () => setState(() {
                      _selection = _selection.copyWith(
                        period: RoomSchedulePeriod.values[index],
                      );
                    }),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _picker({
    required FixedExtentScrollController controller,
    required List<String> values,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 42,
      useMagnifier: true,
      magnification: 1.08,
      onSelectedItemChanged: onChanged,
      children: [
        for (final value in values)
          Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              key: const Key('schedule-clear'),
              onPressed: () {
                Navigator.pop(context);
                widget.onClear();
              },
              child: const Text('Очистить'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 50,
            child: FilledButton(
              key: const Key('schedule-set'),
              onPressed: () {
                final date = _selection.dateToday(widget.now);
                Navigator.pop(context);
                widget.onSet(date);
              },
              style: FilledButton.styleFrom(
                backgroundColor: MargaritavilleColors.scheduled,
                foregroundColor: MargaritavilleColors.roomForeground,
              ),
              child: const Text(
                'Установить',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
