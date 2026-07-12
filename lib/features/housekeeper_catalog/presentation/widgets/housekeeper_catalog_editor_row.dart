import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../domain/catalogs/housekeeper_catalog_rules.dart';
import '../../domain/models/housekeeper.dart';
import '../controllers/housekeeper_catalog_controller.dart';

final class HousekeeperCatalogEditorRow extends ConsumerStatefulWidget {
  const HousekeeperCatalogEditorRow({required this.housekeeper, super.key});

  final Housekeeper housekeeper;

  @override
  ConsumerState<HousekeeperCatalogEditorRow> createState() =>
      _HousekeeperCatalogEditorRowState();
}

final class _HousekeeperCatalogEditorRowState
    extends ConsumerState<HousekeeperCatalogEditorRow> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocus;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.housekeeper.displayName,
    );
    _nameFocus = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant HousekeeperCatalogEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_nameFocus.hasFocus &&
        _nameController.text != widget.housekeeper.displayName) {
      _nameController.text = widget.housekeeper.displayName;
    }
  }

  @override
  void dispose() {
    _nameFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_nameFocus.hasFocus) unawaited(_submitName());
  }

  Future<void> _submitName() async {
    if (_submitting) return;
    final draft = _nameController.text.trim();
    if (draft == widget.housekeeper.displayName) return;
    _submitting = true;
    try {
      final result = await ref
          .read(housekeeperCatalogControllerProvider.notifier)
          .rename(housekeeperId: widget.housekeeper.id, displayName: draft);
      if (!mounted || result.housekeeper != null) return;
      _nameController.text = widget.housekeeper.displayName;
    } catch (_) {
      // Controller state owns the error message; keep the draft for retry.
    } finally {
      _submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = MargaritavilleColors.housekeeper(
      widget.housekeeper.paletteKey,
    );
    return DecoratedBox(
      key: Key('housekeeper-row-${widget.housekeeper.id}'),
      decoration: BoxDecoration(
        color: MargaritavilleColors.surface.withValues(alpha: 0.84),
        border: Border.all(color: color.withValues(alpha: 0.34)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _paletteMenu(color),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: Key('housekeeper-name-${widget.housekeeper.id}'),
                controller: _nameController,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted:
                    _submitFromKeyboard, // interaction-exempt: system-keyboard-submit
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  constraints: const BoxConstraints.tightFor(height: 46),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFromKeyboard(String _) => unawaited(_submitName());

  Widget _paletteMenu(Color color) {
    return PopupMenuButton<String>(
      key: Key('housekeeper-palette-${widget.housekeeper.id}'),
      initialValue: widget.housekeeper.paletteKey,
      tooltip: 'Выбрать цвет',
      onSelected: (paletteKey) =>
          MargaritavilleFeedbackScope.dispatcherOf(context).accept(
            MargaritavilleInteractionIntent.select,
            () => unawaited(_setPalette(paletteKey)),
          ),
      itemBuilder: (_) => [
        for (final paletteKey in HousekeeperCatalogRules.paletteKeys)
          PopupMenuItem(
            value: paletteKey,
            child: Text(_paletteLabel(paletteKey)),
          ),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white70, width: 1.2),
        ),
      ),
    );
  }

  Future<void> _setPalette(String paletteKey) async {
    try {
      await ref
          .read(housekeeperCatalogControllerProvider.notifier)
          .setPalette(
            housekeeperId: widget.housekeeper.id,
            paletteKey: paletteKey,
          );
    } catch (_) {
      // Controller state owns the Russian error message.
    }
  }
}

String _paletteLabel(String paletteKey) {
  return '${paletteKey[0].toUpperCase()}${paletteKey.substring(1)}';
}
