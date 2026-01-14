import 'package:flutter/material.dart';

class WeekHeader extends StatelessWidget {
  const WeekHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onCalendarTap,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final VoidCallback? onCalendarTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: compact ? 16 : 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: compact ? 2 : 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: compact ? 10 : 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPreviousWeek,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          iconSize: compact ? 16 : 24,
        ),
        SizedBox(width: compact ? 4 : 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNextWeek,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          iconSize: compact ? 16 : 24,
        ),
        SizedBox(width: compact ? 4 : 8),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: onCalendarTap,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          iconSize: compact ? 16 : 24,
        ),
        SizedBox(width: compact ? 6 : 12),
        CircleAvatar(
          radius: compact ? 13 : 20,
          backgroundColor: const Color(0xFFE2F2EF),
          child: Icon(
            Icons.person,
            color: const Color(0xFF247A73),
            size: compact ? 15 : 22,
          ),
        ),
      ],
    );
  }
}
