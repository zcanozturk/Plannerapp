import 'package:flutter/material.dart';

import '../../models/planner_task.dart';
import '../atoms/resize_handle.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.slotHeight,
    this.onResizeMinutes,
    this.onResizeStartMinutes,
  });

  final PlannerTask task;
  final double slotHeight;
  final ValueChanged<int>? onResizeMinutes;
  final ValueChanged<int>? onResizeStartMinutes;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _dragAccumulator = 0;

  void _handleDragStart(DragStartDetails details) {
    _dragAccumulator = 0;
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (widget.onResizeMinutes == null) {
      return;
    }
    final stepHeight = widget.slotHeight / 4;
    _dragAccumulator += details.delta.dy;
    final steps = (_dragAccumulator / stepHeight).truncate();
    if (steps != 0) {
      widget.onResizeMinutes?.call(steps * 15);
      _dragAccumulator -= steps * stepHeight;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragAccumulator = 0;
  }

  void _handleVerticalDragUpdateTop(DragUpdateDetails details) {
    if (widget.onResizeStartMinutes == null) {
      return;
    }
    final stepHeight = widget.slotHeight / 4;
    _dragAccumulator += details.delta.dy;
    final steps = (_dragAccumulator / stepHeight).truncate();
    if (steps != 0) {
      widget.onResizeStartMinutes?.call(steps * 15);
      _dragAccumulator -= steps * stepHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.task.height(widget.slotHeight),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final ultraCompact = height < 60;
          final compact = height < 86;
          final showPriority = height >= 64;
          final showSubtitle = height >= 100;
          final showTitle = height >= 34;
          final showHandle = height >= 18;
          final titleLines = height < 90 ? 1 : 2;
          final padding =
              height < 28 ? 2.0 : (height < 50 ? 6.0 : (compact ? 8.0 : 12.0));
          return Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: widget.task.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.task.accent, width: 2),
            ),
            child: ClipRect(
              child: Stack(
                children: [
                  if (showTitle)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showPriority) ...[
                          Text(
                            widget.task.priority.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ultraCompact ? 8 : (compact ? 9 : 10),
                              fontWeight: FontWeight.w700,
                              color: widget.task.accent,
                            ),
                          ),
                          SizedBox(height: compact ? 4 : 6),
                        ],
                        Text(
                          widget.task.title,
                          maxLines: titleLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: ultraCompact ? 11 : (compact ? 12 : 13),
                          ),
                        ),
                        if (showSubtitle) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.task.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5A5A5A),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                        if (showHandle)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: _handleDragStart,
                        onVerticalDragUpdate: _handleVerticalDragUpdate,
                        onVerticalDragEnd: _handleDragEnd,
                              child: ResizeHandle(
                                color: widget.task.accent,
                                compact: compact,
                                isTop: false,
                              ),
                            ),
                          ),
                  if (height >= 28)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: _handleDragStart,
                        onVerticalDragUpdate: _handleVerticalDragUpdateTop,
                        onVerticalDragEnd: _handleDragEnd,
                        child: ResizeHandle(
                          color: widget.task.accent,
                          compact: true,
                          isTop: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
