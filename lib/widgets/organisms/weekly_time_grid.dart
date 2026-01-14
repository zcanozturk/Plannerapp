import 'package:flutter/material.dart';

import '../../models/inbox_task.dart';
import '../../models/planner_task.dart';
import '../../viewmodels/planner_view_model.dart';
import '../molecules/task_card.dart';

class WeeklyTimeGrid extends StatelessWidget {
  const WeeklyTimeGrid({
    super.key,
    required this.layouts,
    required this.onTaskTap,
    required this.onTaskResize,
    required this.onTaskResizeStart,
    required this.onInboxTaskDropped,
  });

  final List<TaskLayout> layouts;
  final ValueChanged<PlannerTask> onTaskTap;
  final void Function(PlannerTask task, int deltaMinutes) onTaskResize;
  final void Function(PlannerTask task, int deltaMinutes) onTaskResizeStart;
  final void Function(InboxTask task, int startMinutes) onInboxTaskDropped;

  @override
  Widget build(BuildContext context) {
    const startHour = 7;
    const endHour = 22;
    final totalSlots = endHour - startHour + 1;
    const headerHeight = 28.0 + 12.0;
    const containerPadding = 12.0;
    final gridKey = GlobalKey();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight =
            constraints.maxHeight - (containerPadding * 2) - headerHeight;
        final slotHeight = availableHeight / totalSlots;
        return Container(
          padding: const EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Planner View',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: List.generate(totalSlots, (index) {
                        final hour = startHour + index;
                        return SizedBox(
                          height: slotHeight,
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9B9B9B),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DragTarget<InboxTask>(
                        onAcceptWithDetails: (details) {
                          final box = gridKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box == null) {
                            return;
                          }
                          final local = box.globalToLocal(details.offset);
                          final minutesFromStart =
                              (local.dy / slotHeight) * 60;
                          final startMinutes =
                              (startHour * 60) + minutesFromStart.round();
                          onInboxTaskDropped(details.data, startMinutes);
                        },
                        builder: (context, _, __) {
                          return Container(
                            key: gridKey,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFF9F7F3),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const horizontalPadding = 8.0;
                                const gap = 8.0;
                                return Stack(
                                  children: [
                                    for (int i = 0; i < totalSlots; i++)
                                      Positioned(
                                        top: i * slotHeight,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 1,
                                          color: const Color(0xFFE3DED7),
                                        ),
                                      ),
                                    for (final layout in layouts)
                                      Positioned(
                                        top: layout.task
                                            .offsetTop(startHour, slotHeight),
                                        left: horizontalPadding +
                                            layout.column *
                                                ((constraints.maxWidth -
                                                        (2 * horizontalPadding) -
                                                        gap * (layout.columnCount - 1)) /
                                                    layout.columnCount +
                                                    gap),
                                        width: (constraints.maxWidth -
                                                (2 * horizontalPadding) -
                                                gap * (layout.columnCount - 1)) /
                                            layout.columnCount,
                                        child: GestureDetector(
                                          onTap: () => onTaskTap(layout.task),
                                          child: TaskCard(
                                            key: ValueKey(layout.task.id),
                                            task: layout.task,
                                            slotHeight: slotHeight,
                                            onResizeMinutes: (deltaMinutes) =>
                                                onTaskResize(
                                                    layout.task, deltaMinutes),
                                            onResizeStartMinutes:
                                                (deltaMinutes) =>
                                                    onTaskResizeStart(
                                                        layout.task,
                                                        deltaMinutes),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
