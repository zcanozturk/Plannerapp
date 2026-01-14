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
  double _dragAccumulatorBottom = 0;
  double _dragAccumulatorTop = 0;
  int _previewDurationDeltaMinutes = 0;
  int _previewStartDeltaMinutes = 0;

  void _handleBottomDragStart(DragStartDetails details) {
    _dragAccumulatorBottom = 0;
    _previewDurationDeltaMinutes = 0;
  }

  void _handleBottomDragUpdate(DragUpdateDetails details) {
    if (widget.onResizeMinutes == null) {
      return;
    }
    final stepHeight = widget.slotHeight / 4;
    _dragAccumulatorBottom += details.delta.dy;
    final steps = (_dragAccumulatorBottom / stepHeight).truncate();
    if (steps != 0) {
      _dragAccumulatorBottom -= steps * stepHeight;
      _previewDurationDeltaMinutes += steps * 15;
      final clamped =
          (widget.task.durationMinutes + _previewDurationDeltaMinutes)
              .clamp(15, 720);
      setState(() {
        _previewDurationDeltaMinutes =
            clamped - widget.task.durationMinutes;
      });
    }
  }

  void _handleBottomDragEnd(DragEndDetails details) {
    if (_previewDurationDeltaMinutes != 0) {
      widget.onResizeMinutes?.call(_previewDurationDeltaMinutes);
    }
    _dragAccumulatorBottom = 0;
    _previewDurationDeltaMinutes = 0;
  }

  void _handleTopDragStart(DragStartDetails details) {
    _dragAccumulatorTop = 0;
    _previewStartDeltaMinutes = 0;
  }

  void _handleTopDragUpdate(DragUpdateDetails details) {
    if (widget.onResizeStartMinutes == null) {
      return;
    }
    final stepHeight = widget.slotHeight / 4;
    _dragAccumulatorTop += details.delta.dy;
    final steps = (_dragAccumulatorTop / stepHeight).truncate();
    if (steps != 0) {
      _dragAccumulatorTop -= steps * stepHeight;
      _previewStartDeltaMinutes += steps * 15;
      final baseStart = widget.task.startTotalMinutes;
      final baseEnd = widget.task.endTotalMinutes;
      final proposedStart = baseStart + _previewStartDeltaMinutes;
      final clampedStart = proposedStart.clamp(0, baseEnd - 15);
      setState(() {
        _previewStartDeltaMinutes = clampedStart - baseStart;
      });
    }
  }

  void _handleTopDragEnd(DragEndDetails details) {
    if (_previewStartDeltaMinutes != 0) {
      widget.onResizeStartMinutes?.call(_previewStartDeltaMinutes);
    }
    _dragAccumulatorTop = 0;
    _previewStartDeltaMinutes = 0;
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _dragAccumulatorBottom = 0;
      _dragAccumulatorTop = 0;
      _previewDurationDeltaMinutes = 0;
      _previewStartDeltaMinutes = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = widget.task.height(widget.slotHeight);
    final previewDurationDelta = _previewStartDeltaMinutes != 0
        ? -_previewStartDeltaMinutes
        : _previewDurationDeltaMinutes;
    final previewHeight =
        baseHeight + (previewDurationDelta / 60) * widget.slotHeight;
    final previewOffset =
        (_previewStartDeltaMinutes / 60) * widget.slotHeight;
    return SizedBox(
      height: previewHeight,
      child: Transform.translate(
        offset: Offset(0, previewOffset),
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
                              onVerticalDragStart: _handleBottomDragStart,
                              onVerticalDragUpdate: _handleBottomDragUpdate,
                              onVerticalDragEnd: _handleBottomDragEnd,
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
                        onVerticalDragStart: _handleTopDragStart,
                        onVerticalDragUpdate: _handleTopDragUpdate,
                        onVerticalDragEnd: _handleTopDragEnd,
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
      ),
    );
  }
}
