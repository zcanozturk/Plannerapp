import 'package:flutter/material.dart';

class ResizeHandle extends StatelessWidget {
  const ResizeHandle({
    super.key,
    required this.color,
    this.compact = false,
    this.isTop = false,
  });

  final Color color;
  final bool compact;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: compact ? 20 : 32,
        height: 6,
        decoration: BoxDecoration(
          color: color.withOpacity(0.55),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
