import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../interaction/application/margaritaville_feedback_controller.dart';
import '../../../interaction/presentation/hold_action_target.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../../../work_session/domain/models/work_session.dart';
import '../summary_header_interaction_policy.dart';
import '../summary_layout_tokens.dart';
import 'summary_selection_puzzle_handle.dart';

final class SummaryHeader extends StatefulWidget {
  const SummaryHeader({
    required this.session,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onOpenSettings,
    required this.onOpenSelection,
    super.key,
  });

  final WorkSession session;
  final RoomDisplayStatus? activeFilter;
  final ValueChanged<RoomDisplayStatus?> onFilterChanged;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSelection;

  @override
  State<SummaryHeader> createState() => _SummaryHeaderState();
}

final class _SummaryHeaderState extends State<SummaryHeader> {
  var _selectionPuzzleProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final feedback = MargaritavilleFeedbackScope.maybeControllerOf(context);
    final rooms = widget.session.activeRooms.toList();
    final completed = rooms
        .where((room) => room.phase == RoomPhase.ready)
        .length;
    final chips = [
      for (final status in const [
        RoomDisplayStatus.open,
        RoomDisplayStatus.ready,
        RoomDisplayStatus.scheduled,
        RoomDisplayStatus.pending,
      ])
        (status: status, count: _count(rooms, status)),
    ];

    return SizedBox(
      key: const Key('summary-header'),
      height: SummaryLayoutTokens.headerHeight,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 10),
            child: Row(
              children: [
                Opacity(
                  key: const Key('summary-settings-opacity'),
                  opacity: SummaryHeaderInteractionPolicy.settingsOpacity(
                    _selectionPuzzleProgress,
                  ),
                  child: HoldActionTarget(
                    key: const Key('summary-open-settings'),
                    semanticLabel: 'Открыть настройки',
                    onHoldStart: feedback?.holdStart,
                    onHoldWarning: feedback?.holdWarning,
                    onHoldCommit: feedback?.holdCommit,
                    onActivate: () => _openSettings(feedback),
                    child: const SizedBox.square(
                      dimension: 48,
                      child: Icon(
                        Icons.menu_rounded,
                        size: 29,
                        color: MargaritavilleColors.secondaryText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ProgressCount(
                          widgetKey: const Key('summary-total-count'),
                          value: rooms.length,
                          color: MargaritavilleColors.pending,
                        ),
                        const SizedBox(width: 7),
                        _ProgressCount(
                          widgetKey: const Key('summary-completed-count'),
                          value: completed,
                          color: MargaritavilleColors.ready,
                        ),
                        const SizedBox(width: 7),
                        _ProgressCount(
                          widgetKey: const Key('summary-remaining-count'),
                          value: rooms.length - completed,
                          color: MargaritavilleColors.open,
                        ),
                        for (final chip in chips) ...[
                          const SizedBox(width: 7),
                          _StatusChip(
                            status: chip.status,
                            count: chip.count,
                            activeFilter: widget.activeFilter,
                            onChanged: widget.onFilterChanged,
                            feedback: feedback,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 94),
              ],
            ),
          ),
          Positioned.fill(
            child: SummarySelectionPuzzleHandle(
              onProgressChanged: (progress) {
                if (progress == _selectionPuzzleProgress) return;
                setState(() => _selectionPuzzleProgress = progress);
              },
              onComplete: () => _openSelection(feedback),
            ),
          ),
        ],
      ),
    );
  }

  int _count(List<RoomState> rooms, RoomDisplayStatus status) {
    return rooms.where((room) => room.displayStatus == status).length;
  }

  void _openSettings(MargaritavilleFeedbackController? feedback) {
    feedback?.settingsOpened();
    widget.onOpenSettings();
  }

  void _openSelection(MargaritavilleFeedbackController? feedback) {
    feedback?.confirm();
    feedback?.selectionOpened();
    widget.onOpenSelection();
  }
}

final class _ProgressCount extends StatelessWidget {
  const _ProgressCount({
    required this.widgetKey,
    required this.value,
    required this.color,
  });

  final Key widgetKey;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widgetKey,
      constraints: const BoxConstraints(minWidth: 26),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
          shadows: const [
            Shadow(
              color: Color(0xD1000000),
              blurRadius: 2.8,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.count,
    required this.activeFilter,
    required this.onChanged,
    required this.feedback,
  });

  final RoomDisplayStatus status;
  final int count;
  final RoomDisplayStatus? activeFilter;
  final ValueChanged<RoomDisplayStatus?> onChanged;
  final MargaritavilleFeedbackController? feedback;

  @override
  Widget build(BuildContext context) {
    final isActive = activeFilter == status;
    final opacity = activeFilter == null || isActive ? 1.0 : 0.48;
    return Semantics(
      button: true,
      selected: isActive,
      label: _semanticLabel,
      child: GestureDetector(
        key: Key('summary-filter-${status.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          feedback?.tap();
          onChanged(isActive ? null : status);
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 38, minHeight: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: opacity),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }

  Color get _color => switch (status) {
    RoomDisplayStatus.pending => MargaritavilleColors.pending,
    RoomDisplayStatus.open => MargaritavilleColors.open,
    RoomDisplayStatus.ready => MargaritavilleColors.ready,
    RoomDisplayStatus.scheduled => MargaritavilleColors.scheduled,
  };

  String get _semanticLabel => switch (status) {
    RoomDisplayStatus.pending => 'Ожидают: $count',
    RoomDisplayStatus.open => 'Открыты: $count',
    RoomDisplayStatus.ready => 'Готовы: $count',
    RoomDisplayStatus.scheduled => 'Назначены: $count',
  };
}
