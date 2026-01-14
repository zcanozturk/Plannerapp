import 'package:flutter/material.dart';

import '../../models/planner_day.dart';
import '../atoms/day_pill.dart';

class DayPills extends StatelessWidget {
  const DayPills({
    super.key,
    required this.days,
    this.compact = false,
    this.onDaySelected,
  });

  final List<PlannerDay> days;
  final bool compact;
  final ValueChanged<int>? onDaySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 42 : 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => SizedBox(width: compact ? 6 : 12),
        itemBuilder: (context, index) => DayPill(
          day: days[index],
          compact: compact,
          onTap: onDaySelected == null ? null : () => onDaySelected!(index),
        ),
      ),
    );
  }
}
