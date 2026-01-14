import 'package:flutter/material.dart';

import '../../models/planner_task.dart';
import '../../viewmodels/planner_view_model.dart';
import '../atoms/category_chip.dart';

class TaskDetailOverlay extends StatelessWidget {
  const TaskDetailOverlay({
    super.key,
    required this.taskId,
    required this.viewModel,
  });

  final String taskId;
  final PlannerViewModel viewModel;

  String _formatTime(BuildContext context, int minutes) {
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  Future<void> _pickStartTime(BuildContext context, PlannerTask task) async {
    final initial = TimeOfDay(hour: task.startHour, minute: task.startMinute);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) {
      viewModel.setTaskStartTime(task.id, selected);
    }
  }

  Future<void> _pickEndTime(BuildContext context, PlannerTask task) async {
    final endMinutes = task.endTotalMinutes;
    final initial = TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) {
      viewModel.setTaskEndTime(task.id, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final task = viewModel.getTaskById(taskId);
        if (task == null) {
          return const SizedBox.shrink();
        }
        final startMinutes = task.startTotalMinutes;
        final endMinutes = task.endTotalMinutes;
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4EF),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.drag_handle, color: Color(0xFFB0B0B0)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Task title',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.title,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 8,
                  children: [
                    CategoryChip(label: 'Work', isSelected: true),
                    CategoryChip(label: 'Personal'),
                    CategoryChip(label: 'Health'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickStartTime(context, task),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(context, startMinutes),
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text('—'),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickEndTime(context, task),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('End', style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(context, endMinutes),
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F2EF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Remind me',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('15 minutes before',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF7E7E7E))),
                          ],
                        ),
                      ),
                      Switch(value: true, onChanged: (_) {}),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6E0E0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete, color: Color(0xFFB45757)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF247A73),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Save task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
