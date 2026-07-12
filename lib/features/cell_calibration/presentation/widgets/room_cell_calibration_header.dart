import 'package:flutter/material.dart';

final class RoomCellCalibrationHeader extends StatelessWidget {
  const RoomCellCalibrationHeader({required this.backButton, super.key});

  final Widget backButton;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 12, 6),
    child: Row(
      children: [
        backButton,
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Стенд ячеек',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              Text('Два пальца на ячейке · данные не сохраняются в смену'),
            ],
          ),
        ),
      ],
    ),
  );
}
