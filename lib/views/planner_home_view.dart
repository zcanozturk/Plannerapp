import 'package:flutter/material.dart';

import '../models/inbox_task.dart';
import '../models/planner_task.dart';
import '../viewmodels/planner_view_model.dart';
import '../widgets/molecules/day_pills.dart';
import '../widgets/molecules/week_header.dart';
import '../widgets/organisms/task_detail_overlay.dart';
import '../widgets/organisms/task_inbox_drawer.dart';
import '../widgets/organisms/weekly_time_grid.dart';

class PlannerHomeView extends StatefulWidget {
  const PlannerHomeView({super.key});

  @override
  State<PlannerHomeView> createState() => _PlannerHomeViewState();
}

class _PlannerHomeViewState extends State<PlannerHomeView> {
  late final PlannerViewModel viewModel;
  bool _isInboxOpen = false;

  @override
  void initState() {
    super.initState();
    viewModel = PlannerViewModel();
    viewModel.initialize();
  }

  void _openTaskDetails(BuildContext context, PlannerTask task) {
    showDialog(
      context: context,
      builder: (_) => TaskDetailOverlay(
        taskId: task.id,
        viewModel: viewModel,
      ),
    );
  }

  Future<void> _pickWeek(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (selected != null) {
      viewModel.setWeek(selected);
    }
  }

  void _addInboxTask(String title) {
    final task = InboxTask(
      id: 'inbox-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: '',
    );
    viewModel.addInboxTask(task);
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => const _AddInboxTaskDialog(),
    );
    if (!context.mounted) {
      return;
    }
    final trimmed = title?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }
    _addInboxTask(trimmed);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final panelWidth = 320.0;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Weekly Planner'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _isInboxOpen = true),
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF7EE), Color(0xFFF1ECE6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WeekHeader(
                          compact: true,
                          title: viewModel.weekTitle,
                          subtitle: viewModel.weekSubtitle,
                          onPreviousWeek: viewModel.previousWeek,
                          onNextWeek: viewModel.nextWeek,
                          onCalendarTap: () => _pickWeek(context),
                        ),
                        const SizedBox(height: 6),
                        DayPills(
                          days: viewModel.days,
                          compact: true,
                          onDaySelected: viewModel.selectDay,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: WeeklyTimeGrid(
                            layouts: viewModel.buildLayouts(),
                            onTaskTap: (task) => _openTaskDetails(context, task),
                            onTaskResize: viewModel.resizeTask,
                            onTaskResizeStart: viewModel.resizeTaskStart,
                            onInboxTaskDropped: viewModel.scheduleInboxTask,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !_isInboxOpen,
                child: AnimatedOpacity(
                  opacity: _isInboxOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: () => setState(() => _isInboxOpen = false),
                    child: Container(color: Colors.black38),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                right: _isInboxOpen ? 0 : -panelWidth,
                child: TaskInboxDrawer(
                  tasks: viewModel.inboxTasks,
                  onAddTaskRequested: () => _showAddTaskDialog(context),
                  onDragStarted: () => setState(() => _isInboxOpen = false),
                  onDeleteTask: viewModel.deleteInboxTask,
                  onClose: () => setState(() => _isInboxOpen = false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddInboxTaskDialog extends StatefulWidget {
  const _AddInboxTaskDialog();

  @override
  State<_AddInboxTaskDialog> createState() => _AddInboxTaskDialogState();
}

class _AddInboxTaskDialogState extends State<_AddInboxTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context, rootNavigator: true)
          .pop(_titleController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter a title';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
