import 'package:flutter/material.dart';

final class RoomCellCalibrationError extends StatelessWidget {
  const RoomCellCalibrationError({
    required this.header,
    required this.error,
    required this.retryButton,
    super.key,
  });

  final Widget header;
  final Object error;
  final Widget retryButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          header,
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Не удалось открыть стенд',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    retryButton,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
