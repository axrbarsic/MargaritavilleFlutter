import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/hold_action_button.dart';
import '../../work_session/domain/catalogs/margaritaville_room_catalog.dart';
import '../../work_session/domain/models/work_session.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import 'widgets/housekeeper_selector.dart';
import 'widgets/setup_room_grid.dart';

final class WorkSetupScreen extends ConsumerStatefulWidget {
  const WorkSetupScreen({required this.session, super.key});

  final WorkSession session;

  @override
  ConsumerState<WorkSetupScreen> createState() => _WorkSetupScreenState();
}

final class _WorkSetupScreenState extends ConsumerState<WorkSetupScreen> {
  late String _assignmentId;
  var _territoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _assignmentId = widget.session.activeAssignments.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final assignments = widget.session.activeAssignments.toList();
    final selectedAssignment =
        widget.session.assignment(_assignmentId) ?? assignments.first;
    final territory = MargaritavilleRoomCatalog.territories[_territoryIndex];
    final selectedCount = widget.session.activeRooms.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка смены'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Выбрано номеров: $selectedCount',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Text('Уборщица', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            HousekeeperSelector(
              assignments: assignments,
              selectedAssignmentId: selectedAssignment.id,
              onSelected: (value) => setState(() => _assignmentId = value),
            ),
            const SizedBox(height: 12),
            Text('Зона', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (
                  var index = 0;
                  index < MargaritavilleRoomCatalog.territories.length;
                  index++
                )
                  ChoiceChip(
                    label: Text(
                      MargaritavilleRoomCatalog.territories[index].id,
                    ),
                    selected: index == _territoryIndex,
                    onSelected: (_) => setState(() => _territoryIndex = index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            HoldActionButton(
              key: const Key('lock-workday'),
              label: 'Начать смену',
              enabled: selectedCount > 0,
              onLongPress: _lockWorkday,
            ),
            const SizedBox(height: 18),
            Text(
              '${selectedAssignment.housekeeper.displayName} · ${territory.id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Удерживайте номер для выбора. Занятые номера подписаны именем.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SetupRoomGrid(
              roomNumbers: territory.rooms,
              session: widget.session,
              selectedAssignment: selectedAssignment,
              onRoomHeld: _toggleRoom,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRoom(String roomNumber) async {
    final status = await ref
        .read(workSessionControllerProvider.notifier)
        .toggleRoomSelection(
          assignmentId: _assignmentId,
          roomNumber: roomNumber,
        );
    if (!mounted || status != WorkSessionMutationStatus.blocked) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Номер уже назначен другой уборщице')),
    );
  }

  Future<void> _lockWorkday() async {
    final status = await ref
        .read(workSessionControllerProvider.notifier)
        .lockWorkday();
    if (!mounted || status != WorkSessionMutationStatus.ignored) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сначала выберите хотя бы один номер')),
    );
  }
}
