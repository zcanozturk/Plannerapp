import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/inbox_task.dart';
import '../models/planner_task.dart';

class TaskStorageService {
  static const _scheduledKey = 'scheduled_tasks';
  static const _inboxKey = 'inbox_tasks';

  Future<List<PlannerTask>> loadScheduledTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scheduledKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => PlannerTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveScheduledTasks(List<PlannerTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_scheduledKey, encoded);
  }

  Future<List<InboxTask>> loadInboxTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_inboxKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => InboxTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveInboxTasks(List<InboxTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_inboxKey, encoded);
  }
}
