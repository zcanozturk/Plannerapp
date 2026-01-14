import 'package:flutter/material.dart';

class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    required this.color,
    required this.accent,
    required this.priority,
  });

  final String id;
  final String title;
  final String subtitle;
  final int startHour;
  final int startMinute;
  final int durationMinutes;
  final Color color;
  final Color accent;
  final String priority;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'startHour': startHour,
      'startMinute': startMinute,
      'durationMinutes': durationMinutes,
      'color': color.value,
      'accent': accent.value,
      'priority': priority,
    };
  }

  factory PlannerTask.fromJson(Map<String, dynamic> json) {
    return PlannerTask(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int,
      durationMinutes: json['durationMinutes'] as int,
      color: Color(json['color'] as int),
      accent: Color(json['accent'] as int),
      priority: json['priority'] as String,
    );
  }

  PlannerTask copyWith({
    int? startHour,
    int? startMinute,
    int? durationMinutes,
  }) {
    return PlannerTask(
      id: id,
      title: title,
      subtitle: subtitle,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      color: color,
      accent: accent,
      priority: priority,
    );
  }

  int get startTotalMinutes => startHour * 60 + startMinute;

  int get endTotalMinutes => startTotalMinutes + durationMinutes;

  double offsetTop(int startBaseHour, double slotHeight) {
    final hourOffset = startHour - startBaseHour;
    final minuteOffset = startMinute / 60;
    return (hourOffset + minuteOffset) * slotHeight + 6;
  }

  double height(double slotHeight) {
    return (durationMinutes / 60) * slotHeight - 6;
  }
}
