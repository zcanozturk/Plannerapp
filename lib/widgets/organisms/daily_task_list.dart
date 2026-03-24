import 'package:flutter/material.dart';

import '../../models/inbox_task.dart';
import '../../models/planner_task.dart';
import '../molecules/task_list_card.dart';

class DailyTaskList extends StatelessWidget {
  const DailyTaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onReorder,
    required this.onInboxTaskDropped,
  });

  final List<PlannerTask> tasks;
  final ValueChanged<PlannerTask> onTaskTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<InboxTask> onInboxTaskDropped;

  @override
  Widget build(BuildContext context) {
    const containerPadding = 12.0;
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
            'Daily Order',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DragTarget<InboxTask>(
              onAcceptWithDetails: (details) =>
                  onInboxTaskDropped(details.data),
              builder: (context, candidateData, _) {
                final isActive = candidateData.isNotEmpty;
                final emptyState = Center(
                  child: Text(
                    'Drop tasks here to build your day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF247A73)
                          : const Color(0xFF9B9B9B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFEEF7F5)
                        : const Color(0xFFF9F7F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: tasks.isEmpty
                      ? emptyState
                      : ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: tasks.length,
                          onReorder: onReorder,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Padding(
                              key: ValueKey(task.id),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TaskListCard(
                                task: task,
                                index: index,
                                onTap: () => onTaskTap(task),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
