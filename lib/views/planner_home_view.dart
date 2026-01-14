import 'package:flutter/material.dart';

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
        return Scaffold(
          endDrawer: TaskInboxDrawer(tasks: viewModel.inboxTasks),
          appBar: AppBar(
            title: const Text('Weekly Planner'),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          body: Container(
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
                    const WeekHeader(compact: true),
                    const SizedBox(height: 6),
                    DayPills(days: viewModel.days, compact: true),
                    const SizedBox(height: 8),
                    Expanded(
                      child: WeeklyTimeGrid(
                        layouts: viewModel.buildLayouts(),
                        onTaskTap: (task) => _openTaskDetails(context, task),
                        onTaskResize: viewModel.resizeTask,
                        onTaskResizeStart: viewModel.resizeTaskStart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
