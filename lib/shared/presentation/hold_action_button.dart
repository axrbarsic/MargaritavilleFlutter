import 'package:flutter/material.dart';

final class HoldActionButton extends StatelessWidget {
  const HoldActionButton({
    required this.label,
    required this.onLongPress,
    this.hint = 'Удерживайте для подтверждения',
    this.enabled = true,
    this.icon = Icons.touch_app_rounded,
    super.key,
  });

  final String label;
  final String hint;
  final bool enabled;
  final IconData icon;
  final Future<void> Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onLongPress: enabled ? onLongPress : null,
      child: Material(
        color: enabled ? colors.primaryContainer : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: enabled ? onLongPress : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, color: enabled ? colors.onPrimaryContainer : null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          hint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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
