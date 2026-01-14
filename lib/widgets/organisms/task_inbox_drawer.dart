import 'package:flutter/material.dart';

import '../../models/inbox_task.dart';
import '../molecules/task_inbox_item.dart';

class TaskInboxDrawer extends StatelessWidget {
  const TaskInboxDrawer({super.key, required this.tasks});

  final List<InboxTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
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
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
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
                    return TaskInboxItem(task: tasks[index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
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
