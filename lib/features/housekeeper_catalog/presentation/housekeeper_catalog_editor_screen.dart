import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/housekeeper_catalog_controller.dart';
import 'widgets/housekeeper_catalog_editor_row.dart';

final class HousekeeperCatalogEditorScreen extends ConsumerStatefulWidget {
  const HousekeeperCatalogEditorScreen({super.key});

  @override
  ConsumerState<HousekeeperCatalogEditorScreen> createState() =>
      _HousekeeperCatalogEditorScreenState();
}

final class _HousekeeperCatalogEditorScreenState
    extends ConsumerState<HousekeeperCatalogEditorScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    try {
      final result = await ref
          .read(housekeeperCatalogControllerProvider.notifier)
          .add(_nameController.text);
      if (mounted && result.housekeeper != null) _nameController.clear();
    } catch (_) {
      // Controller state owns the Russian error message; keep the draft.
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(housekeeperCatalogProvider);
    final editor = ref.watch(housekeeperCatalogControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              sliver: SliverList.list(
                children: [
                  _header(context),
                  const SizedBox(height: 18),
                  Text(
                    editor.message,
                    key: const Key('housekeeper-catalog-status'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _addRow(editor.busy),
                  const SizedBox(height: 10),
                  catalog.when(
                    data: (housekeepers) => Column(
                      children: [
                        for (final housekeeper in housekeepers) ...[
                          HousekeeperCatalogEditorRow(
                            key: ValueKey(housekeeper.id),
                            housekeeper: housekeeper,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                    error: (error, _) =>
                        Text('Не удалось открыть список: $error'),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          key: const Key('housekeeper-catalog-back'),
          onPressed: () => Navigator.pop(context),
          iconSize: 24,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Уборщицы',
                maxLines: 1,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
              ),
              Text(
                'Имена, цвета и назначения тележек для первого экрана Margaritaville.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addRow(bool busy) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('housekeeper-add-name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: busy ? null : (_) => unawaited(_add()),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: 'Имя',
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.24),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              constraints: const BoxConstraints.tightFor(height: 48),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox.square(
          dimension: 48,
          child: FilledButton(
            key: const Key('housekeeper-add-submit'),
            onPressed: busy ? null : () => unawaited(_add()),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Icon(Icons.add_rounded, size: 18),
          ),
        ),
      ],
    );
  }
}
