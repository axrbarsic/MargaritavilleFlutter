import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/interaction/domain/margaritaville_interaction_intent.dart';
import '../features/interaction/presentation/margaritaville_feedback_scope.dart';

final class RoomMediaRecoveryGate<T> extends StatelessWidget {
  const RoomMediaRecoveryGate({
    required this.recovery,
    required this.onRetry,
    required this.child,
    super.key,
  });

  static const loadingKey = Key('room-media-recovery-loading');
  static const errorKey = Key('room-media-recovery-error');
  static const retryKey = Key('room-media-recovery-retry');

  final AsyncValue<T> recovery;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) => recovery.when(
    data: (_) => child,
    loading: () => const Scaffold(
      key: loadingKey,
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Проверяю локальные медиа...'),
          ],
        ),
      ),
    ),
    error: (_, _) => Scaffold(
      key: errorKey,
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 42),
              const SizedBox(height: 16),
              const Text(
                'Не удалось восстановить локальные медиа',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: retryKey,
                onPressed: () => MargaritavilleFeedbackScope.dispatcherOf(
                  context,
                ).accept(MargaritavilleInteractionIntent.retry, onRetry),
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
