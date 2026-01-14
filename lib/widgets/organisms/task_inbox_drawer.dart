import 'package:flutter/material.dart';

import '../../models/inbox_task.dart';
import '../molecules/task_inbox_item.dart';

class TaskInboxDrawer extends StatelessWidget {
  const TaskInboxDrawer({
    super.key,
    required this.tasks,
    required this.onAddTaskRequested,
    required this.onDragStarted,
    required this.onDeleteTask,
    this.onClose,
  });

  final List<InboxTask> tasks;
  final VoidCallback onAddTaskRequested;
  final VoidCallback onDragStarted;
  final void Function(String taskId) onDeleteTask;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: const Color(0xFFF7F4EF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 8),
                  const Text(
                    'Weekly Planner',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Task Inbox',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${tasks.length} unscheduled tasks',
                style: const TextStyle(color: Color(0xFF808080)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return TaskInboxItem(
                      task: tasks[index],
                      onDragStarted: onDragStarted,
                      onDelete: () => onDeleteTask(tasks[index].id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddTaskRequested,
                  icon: const Icon(Icons.add),
                  label: const Text('Add task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF247A73),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
