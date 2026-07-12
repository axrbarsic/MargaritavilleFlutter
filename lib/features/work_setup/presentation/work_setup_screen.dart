import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../housekeeper_catalog/domain/catalogs/margaritaville_housekeeper_catalog.dart';
import '../../housekeeper_catalog/domain/models/housekeeper.dart';
import '../../housekeeper_catalog/presentation/controllers/housekeeper_catalog_controller.dart';
import '../../interaction/application/margaritaville_interaction_dispatcher.dart';
import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../work_session/domain/models/work_assignment.dart';
import '../../work_session/domain/models/work_session.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import 'widgets/housekeeper_selector.dart';
import 'widgets/work_setup_assignment_card.dart';

final class WorkSetupScreen extends ConsumerStatefulWidget {
  const WorkSetupScreen({required this.session, super.key});

  final WorkSession session;

  @override
  ConsumerState<WorkSetupScreen> createState() => _WorkSetupScreenState();
}

final class _WorkSetupScreenState extends ConsumerState<WorkSetupScreen> {
  String? _focusedAssignmentId;

  @override
  void initState() {
    super.initState();
    _focusedAssignmentId = _firstAssignmentId(widget.session);
  }

  @override
  void didUpdateWidget(covariant WorkSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusedAssignmentId == null ||
        widget.session.assignment(_focusedAssignmentId!) == null) {
      _focusedAssignmentId = _firstAssignmentId(widget.session);
    }
  }

  @override
  Widget build(BuildContext context) {
    MargaritavilleInteractionDispatcher interactions() =>
        MargaritavilleFeedbackScope.dispatcherOf(context);
    final assignments = widget.session.activeAssignments.toList()
      ..sort((left, right) => left.cartNumber.compareTo(right.cartNumber));
    final persistedCatalog = ref.watch(housekeeperCatalogProvider).value;
    final housekeepers =
        persistedCatalog ??
        MargaritavilleHousekeeperCatalog.housekeepers(widget.session.startedAt);
    final catalogById = {for (final value in housekeepers) value.id: value};
    final selectedHousekeeperIds = assignments
        .map((value) => value.housekeeper.id)
        .toSet();
    final focused = _focusedAssignmentId == null
        ? null
        : widget.session.assignment(_focusedAssignmentId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Рабочий список')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 26),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Выбрано: ${widget.session.activeRooms.length}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                FilledButton(
                  key: const Key('lock-workday'),
                  onPressed: widget.session.activeRooms.isEmpty
                      ? null
                      : () => interactions().acceptAsync(
                          MargaritavilleInteractionIntent.confirm,
                          _lockWorkday,
                        ),
                  child: const Text('Начать'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            HousekeeperSelector(
              housekeepers: housekeepers,
              selectedHousekeeperIds: selectedHousekeeperIds,
              focusedHousekeeperId: focused?.housekeeper.id,
              onSelected: (housekeeperId) {
                final intent = selectedHousekeeperIds.contains(housekeeperId)
                    ? MargaritavilleInteractionIntent.deselect
                    : MargaritavilleInteractionIntent.select;
                interactions().acceptAsync(
                  intent,
                  () => _toggleHousekeeper(
                    housekeepers.firstWhere(
                      (value) => value.id == housekeeperId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (assignments.isEmpty)
              Container(
                key: const Key('setup-empty-hint'),
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 140),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('Выбери уборщицу сверху.'),
              )
            else
              for (final assignment in assignments) ...[
                WorkSetupAssignmentCard(
                  session: widget.session,
                  assignment: assignment,
                  housekeeper:
                      catalogById[assignment.housekeeper.id] ??
                      assignment.housekeeper,
                  catalogById: catalogById,
                  focused: assignment.id == _focusedAssignmentId,
                  onFocus: () {
                    if (_focusedAssignmentId == assignment.id) return;
                    interactions().accept(
                      MargaritavilleInteractionIntent.select,
                      () =>
                          setState(() => _focusedAssignmentId = assignment.id),
                    );
                  },
                  onRemove: () => interactions().acceptAsync(
                    MargaritavilleInteractionIntent.deselect,
                    () => _toggleHousekeeper(assignment.housekeeper),
                  ),
                  onTerritoryChanged: (territoryId) =>
                      interactions().acceptAsync(
                        MargaritavilleInteractionIntent.select,
                        () => _setTerritory(assignment, territoryId),
                      ),
                  onRoomTap: (roomNumber) {
                    final selected = assignment.room(roomNumber) != null;
                    interactions().acceptAsync(
                      selected
                          ? MargaritavilleInteractionIntent.deselect
                          : MargaritavilleInteractionIntent.select,
                      () => _toggleRoom(assignment, roomNumber),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleHousekeeper(Housekeeper housekeeper) async {
    final assignmentId = await ref
        .read(workSessionControllerProvider.notifier)
        .toggleHousekeeperWorkItem(housekeeper);
    if (!mounted) return;
    setState(() {
      _focusedAssignmentId = assignmentId == null || assignmentId.isEmpty
          ? _firstAssignmentId(ref.read(workSessionControllerProvider).value)
          : assignmentId;
    });
  }

  Future<void> _setTerritory(
    WorkAssignment assignment,
    String territoryId,
  ) async {
    await ref
        .read(workSessionControllerProvider.notifier)
        .setAssignmentTerritory(
          assignmentId: assignment.id,
          territoryId: territoryId,
        );
    if (mounted) setState(() => _focusedAssignmentId = assignment.id);
  }

  Future<void> _toggleRoom(WorkAssignment assignment, String roomNumber) async {
    final status = await ref
        .read(workSessionControllerProvider.notifier)
        .toggleRoomSelection(
          assignmentId: assignment.id,
          roomNumber: roomNumber,
        );
    if (!mounted) return;
    setState(() => _focusedAssignmentId = assignment.id);
    if (status != WorkSessionMutationStatus.blocked) return;
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

String? _firstAssignmentId(WorkSession? session) {
  if (session == null) return null;
  final iterator = session.activeAssignments.iterator;
  return iterator.moveNext() ? iterator.current.id : null;
}
