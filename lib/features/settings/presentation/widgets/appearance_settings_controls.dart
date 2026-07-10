import 'package:flutter/material.dart';

final class AppearanceSettingToggleRow extends StatelessWidget {
  const AppearanceSettingToggleRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(icon, color: const Color(0xFF7BFFA4), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        value ? 'Вкл' : 'Выкл',
                        style: const TextStyle(
                          color: Color(0xFF8DFFA8),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFB8C9BD),
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

final class AppearanceSettingSliderRow extends StatefulWidget {
  const AppearanceSettingSliderRow({
    required this.title,
    required this.icon,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.defaultValue,
    required this.valueLabel,
    required this.onChanged,
    super.key,
  });

  final String title;
  final IconData icon;
  final double value;
  final double minimum;
  final double maximum;
  final double defaultValue;
  final String Function(double value) valueLabel;
  final ValueChanged<double> onChanged;

  @override
  State<AppearanceSettingSliderRow> createState() =>
      _AppearanceSettingSliderRowState();
}

final class _AppearanceSettingSliderRowState
    extends State<AppearanceSettingSliderRow> {
  late double _value = widget.value;

  @override
  void didUpdateWidget(covariant AppearanceSettingSliderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 9),
      child: Column(
        children: [
          Row(
            children: [
              Icon(widget.icon, color: const Color(0xFF7BFFA4), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                widget.valueLabel(_value),
                style: const TextStyle(
                  color: Color(0xFF8DFFA8),
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                tooltip: 'Сбросить',
                onPressed: () {
                  setState(() => _value = widget.defaultValue);
                  widget.onChanged(widget.defaultValue);
                },
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ],
          ),
          Slider.adaptive(
            value: _value,
            min: widget.minimum,
            max: widget.maximum,
            onChanged: (value) => setState(() => _value = value),
            onChangeEnd: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
