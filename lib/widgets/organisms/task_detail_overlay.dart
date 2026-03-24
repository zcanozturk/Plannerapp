import 'package:flutter/material.dart';

import '../../models/planner_task.dart';
import '../../viewmodels/planner_view_model.dart';
import '../atoms/category_chip.dart';

class TaskDetailOverlay extends StatefulWidget {
  const TaskDetailOverlay({
    super.key,
    required this.taskId,
    required this.viewModel,
  });

  final String taskId;
  final PlannerViewModel viewModel;

  @override
  State<TaskDetailOverlay> createState() => _TaskDetailOverlayState();
}

class _TaskDetailOverlayState extends State<TaskDetailOverlay> {
  late final TextEditingController _notesController;
  late final FocusNode _notesFocus;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _notesFocus = FocusNode();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }


  void _saveNotes(PlannerTask task) {
    final updated = task.copyWith(notes: _notesController.text.trim());
    widget.viewModel.updateTask(updated);
    Navigator.of(context).pop();
  }

  void _deleteTask(PlannerTask task) {
    widget.viewModel.deleteTask(task.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final task = widget.viewModel.getTaskById(widget.taskId);
        if (task == null) {
          return const SizedBox.shrink();
        }
        if (!_notesFocus.hasFocus && _notesController.text != task.notes) {
          _notesController.text = task.notes;
        }
        final viewInsets = MediaQuery.of(context).viewInsets;
        final availableHeight = MediaQuery.of(context).size.height -
            viewInsets.bottom -
            48;
        final maxHeight = availableHeight.clamp(280.0, double.infinity);
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Colors.transparent,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                        child:
                            Icon(Icons.drag_handle, color: Color(0xFFB0B0B0)),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
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
                        'Notes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _notesController,
                          focusNode: _notesFocus,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add details...',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text('15 minutes before',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF7E7E7E))),
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
                          InkWell(
                            onTap: () => _deleteTask(task),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6E0E0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Color(0xFFB45757)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveNotes(task),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF247A73),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
              ),
            ),
          ),
        );
      },
    );
  }
}
