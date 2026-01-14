import 'package:flutter/material.dart';

import '../../models/inbox_task.dart';

class TaskInboxItem extends StatelessWidget {
  const TaskInboxItem({
    super.key,
    required this.task,
    this.onDragStarted,
    this.onDelete,
  });

  final InboxTask task;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: Color(0xFF9B9B9B)),
        ],
      ),
    );
    return LongPressDraggable<InboxTask>(
      data: task,
      onDragStarted: onDragStarted,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Opacity(opacity: 0.9, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: Stack(
        children: [
          card,
          Positioned(
            right: 6,
            top: 6,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDelete,
              color: const Color(0xFF9B9B9B),
              splashRadius: 16,
              tooltip: 'Delete',
            ),
          ),
        ],
      ),
    );
  }
}
