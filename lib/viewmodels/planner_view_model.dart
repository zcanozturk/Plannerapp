import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/inbox_task.dart';
import '../models/planner_day.dart';
import '../models/planner_task.dart';
import '../services/task_storage_service.dart';

class PlannerViewModel extends ChangeNotifier {
  PlannerViewModel({TaskStorageService? storageService})
      : _storageService = storageService ?? TaskStorageService() {
    _seedDefaults();
  }

  final TaskStorageService _storageService;

  final List<PlannerDay> days = const [
    PlannerDay(label: 'Mon', date: '11'),
    PlannerDay(label: 'Tue', date: '12'),
    PlannerDay(label: 'Wed', date: '13', isActive: true),
    PlannerDay(label: 'Thu', date: '14'),
    PlannerDay(label: 'Fri', date: '15'),
    PlannerDay(label: 'Sat', date: '16'),
    PlannerDay(label: 'Sun', date: '17'),
  ];

  List<PlannerTask> scheduledTasks = [];

  List<InboxTask> inboxTasks = [];

  void _seedDefaults() {
    scheduledTasks = [
      PlannerTask(
        id: 'task-1',
        title: 'Morning Standup & Sprint Plan',
        subtitle: 'Main Office',
        startHour: 9,
        startMinute: 0,
        durationMinutes: 90,
        color: Color(0xFFF6D8BF),
        accent: Color(0xFFDD8E5F),
        priority: 'High priority',
      ),
      PlannerTask(
        id: 'task-2',
        title: 'Design System Review',
        subtitle: 'Team workspace',
        startHour: 10,
        startMinute: 30,
        durationMinutes: 120,
        color: Color(0xFFE2F2EF),
        accent: Color(0xFF2D9C92),
        priority: 'Working',
      ),
      PlannerTask(
        id: 'task-3',
        title: 'Gym Session',
        subtitle: 'Done',
        startHour: 11,
        startMinute: 0,
        durationMinutes: 60,
        color: Color(0xFFEAF1E6),
        accent: Color(0xFF7FA96A),
        priority: 'Done',
      ),
      PlannerTask(
        id: 'task-4',
        title: 'Quick Lunch',
        subtitle: 'Break',
        startHour: 13,
        startMinute: 0,
        durationMinutes: 45,
        color: Color(0xFFF2EEE8),
        accent: Color(0xFFB7A89C),
        priority: 'Reset',
      ),
    ];
    inboxTasks = const [
      InboxTask(
        id: 'inbox-1',
        title: 'Review quarterly budget',
        subtitle: 'High priority',
      ),
      InboxTask(
        id: 'inbox-2',
        title: 'Call landlord',
        subtitle: 'Rent increase follow-up',
      ),
      InboxTask(
        id: 'inbox-3',
        title: 'Weekly sync preparation',
        subtitle: 'Update project board',
      ),
    ];
  }

  Future<void> initialize() async {
    final storedScheduled = await _storageService.loadScheduledTasks();
    final storedInbox = await _storageService.loadInboxTasks();
    if (storedScheduled.isNotEmpty) {
      scheduledTasks = storedScheduled;
    }
    if (storedInbox.isNotEmpty) {
      inboxTasks = storedInbox;
    }
    notifyListeners();
  }

  List<TaskLayout> buildLayouts() {
    final sorted = [...scheduledTasks]
      ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));
    final layouts = <TaskLayout>[];
    final active = <TaskLayout>[];
    final group = <TaskLayout>[];
    int maxColumnsInGroup = 0;

    void closeGroup() {
      for (final item in group) {
        item.columnCount = maxColumnsInGroup == 0 ? 1 : maxColumnsInGroup;
      }
      group.clear();
      maxColumnsInGroup = 0;
    }

    for (final task in sorted) {
      active.removeWhere(
        (entry) => entry.task.endTotalMinutes <= task.startTotalMinutes,
      );
      if (active.isEmpty && group.isNotEmpty) {
        closeGroup();
      }

      final usedColumns = active.map((e) => e.column).toSet();
      int column = 0;
      while (usedColumns.contains(column)) {
        column++;
      }

      final layout = TaskLayout(task: task, column: column);
      layouts.add(layout);
      active.add(layout);
      group.add(layout);
      if (column + 1 > maxColumnsInGroup) {
        maxColumnsInGroup = column + 1;
      }
    }

    if (group.isNotEmpty) {
      closeGroup();
    }
    return layouts;
  }

  PlannerTask? getTaskById(String taskId) {
    try {
      return scheduledTasks.firstWhere((task) => task.id == taskId);
    } catch (_) {
      return null;
    }
  }

  void resizeTask(PlannerTask task, int deltaMinutes) {
    final index = scheduledTasks.indexWhere((item) => item.id == task.id);
    if (index == -1 || deltaMinutes == 0) {
      return;
    }
    final current = scheduledTasks[index];
    final nextDuration = (current.durationMinutes + deltaMinutes).clamp(15, 720);
    if (nextDuration == current.durationMinutes) {
      return;
    }
    scheduledTasks[index] = current.copyWith(durationMinutes: nextDuration);
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void resizeTaskStart(PlannerTask task, int deltaMinutes) {
    final index = scheduledTasks.indexWhere((item) => item.id == task.id);
    if (index == -1 || deltaMinutes == 0) {
      return;
    }
    final current = scheduledTasks[index];
    final endMinutes = current.endTotalMinutes;
    final proposedStart = current.startTotalMinutes + deltaMinutes;
    final clampedStart = proposedStart.clamp(0, endMinutes - 15);
    final nextDuration = endMinutes - clampedStart;
    if (nextDuration == current.durationMinutes &&
        clampedStart == current.startTotalMinutes) {
      return;
    }
    final nextHour = clampedStart ~/ 60;
    final nextMinute = clampedStart % 60;
    scheduledTasks[index] = current.copyWith(
      startHour: nextHour,
      startMinute: nextMinute,
      durationMinutes: nextDuration,
    );
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void setTaskStartTime(String taskId, TimeOfDay time) {
    final index = scheduledTasks.indexWhere((item) => item.id == taskId);
    if (index == -1) {
      return;
    }
    final current = scheduledTasks[index];
    final roundedStart = _roundToQuarterHour(_timeToMinutes(time));
    final maxStart = (24 * 60) - 15;
    final clampedStart = roundedStart.clamp(0, maxStart);
    final maxDuration = (24 * 60) - clampedStart;
    final nextDuration = current.durationMinutes.clamp(15, maxDuration);
    final nextHour = clampedStart ~/ 60;
    final nextMinute = clampedStart % 60;
    scheduledTasks[index] = current.copyWith(
      startHour: nextHour,
      startMinute: nextMinute,
      durationMinutes: nextDuration,
    );
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void setTaskEndTime(String taskId, TimeOfDay time) {
    final index = scheduledTasks.indexWhere((item) => item.id == taskId);
    if (index == -1) {
      return;
    }
    final current = scheduledTasks[index];
    final startMinutes = current.startTotalMinutes;
    final roundedEnd = _roundToQuarterHour(_timeToMinutes(time));
    final maxEnd = (startMinutes + 720).clamp(0, 24 * 60);
    final minEnd = startMinutes + 15;
    final clampedEnd = roundedEnd.clamp(minEnd, maxEnd);
    final nextDuration = (clampedEnd - startMinutes).clamp(15, 720);
    scheduledTasks[index] = current.copyWith(durationMinutes: nextDuration);
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void addTask(PlannerTask task) {
    scheduledTasks = [...scheduledTasks, task];
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void updateTask(PlannerTask task) {
    final index = scheduledTasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      return;
    }
    scheduledTasks[index] = task;
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    final next = scheduledTasks.where((task) => task.id != taskId).toList();
    if (next.length == scheduledTasks.length) {
      return;
    }
    scheduledTasks = next;
    _storageService.saveScheduledTasks(scheduledTasks);
    notifyListeners();
  }

  void addInboxTask(InboxTask task) {
    inboxTasks = [...inboxTasks, task];
    _storageService.saveInboxTasks(inboxTasks);
    notifyListeners();
  }

  void updateInboxTask(InboxTask task) {
    final index = inboxTasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      return;
    }
    inboxTasks[index] = task;
    _storageService.saveInboxTasks(inboxTasks);
    notifyListeners();
  }

  void deleteInboxTask(String taskId) {
    final next = inboxTasks.where((task) => task.id != taskId).toList();
    if (next.length == inboxTasks.length) {
      return;
    }
    inboxTasks = next;
    _storageService.saveInboxTasks(inboxTasks);
    notifyListeners();
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  int _roundToQuarterHour(int minutes) {
    final rounded = (minutes / 15).round() * 15;
    return rounded.clamp(0, (24 * 60) - 1);
  }
}

class TaskLayout {
  TaskLayout({
    required this.task,
    required this.column,
    this.columnCount = 1,
  });

  final PlannerTask task;
  final int column;
  int columnCount;
}
