import 'package:flutter/material.dart';

import '../../models/planner_day.dart';

class DayPill extends StatelessWidget {
  const DayPill({super.key, required this.day, this.compact = false});

  final PlannerDay day;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 44 : 64,
      padding: EdgeInsets.symmetric(vertical: compact ? 3 : 10),
      decoration: BoxDecoration(
        color: day.isActive ? const Color(0xFF247A73) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (day.isActive)
            const BoxShadow(
              color: Color(0x33247A73),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.label.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 7.5 : 11,
              fontWeight: FontWeight.w600,
              color: day.isActive ? Colors.white70 : const Color(0xFF8D8D8D),
            ),
          ),
          SizedBox(height: compact ? 2 : 6),
          Text(
            day.date,
            style: TextStyle(
              fontSize: compact ? 13 : 18,
              fontWeight: FontWeight.w700,
              color: day.isActive ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
