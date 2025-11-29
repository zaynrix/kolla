import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/subtask.dart';
import '../../../models/work_step.dart';
import '../../../models/enums.dart';
import '../../../models/actor.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_actor_service.dart';
import '../../shared/widgets/priority_badge.dart';

class JiraTaskCard extends StatelessWidget {
  final Task task;
  final WorkStep? workStep;
  final VoidCallback? onTap;
  final Function(SubTask)? onSubTaskComplete;

  const JiraTaskCard({
    super.key,
    required this.task,
    this.workStep,
    this.onTap,
    this.onSubTaskComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hoursUntilDeadline = task.deadline.difference(DateTime.now()).inHours;
    final isUrgent = hoursUntilDeadline < 24 && hoursUntilDeadline >= 0;
    final isOverdue = hoursUntilDeadline < 0;

    return _WebOptimizedCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Name
                      Text(
                        task.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Work Step Name (if provided)
                      if (workStep != null)
                        Text(
                          workStep!.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
                // Priority Badge
                if (workStep != null) ...[
                  const SizedBox(width: 12),
                  PriorityBadge(
                    priority: workStep!.getEffectivePriority(
                      task.deadline,
                      task.workSteps
                          .where((ws) =>
                              ws.sequenceOrder > workStep!.sequenceOrder &&
                              ws.status != WorkStepStatus.completed)
                          .length,
                    ),
                  ),
                ],
              ],
            ),
            
            // Subtasks Section
            if (task.subTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Subtasks (${task.completedSubTasksCount}/${task.subTasks.length})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...task.subTasks.map((subTask) => _SubTaskItem(
                          subTask: subTask,
                          onComplete: () => onSubTaskComplete?.call(subTask),
                        )),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Footer Row
            Row(
              children: [
                // Assignee Avatar
                if (task.assignedToActorId != null)
                  FutureBuilder<Actor>(
                    future: context.read<IActorService>().getActor(task.assignedToActorId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final actor = snapshot.data!;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              actor.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                
                // Progress Bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.progressPercentage / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        task.status == TaskStatus.overdue
                            ? AppColors.overdue
                            : task.status == TaskStatus.atRisk
                                ? AppColors.atRisk
                                : AppColors.onTrack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${task.progressPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            
            // Status Badge
            if (isOverdue || isUrgent) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOverdue ? AppColors.overdue : AppColors.warning)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOverdue ? 'OVERDUE' : 'URGENT',
                  style: TextStyle(
                    color: isOverdue ? AppColors.overdue : AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Web-optimized card with hover effects
class _WebOptimizedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _WebOptimizedCard({
    required this.child,
    this.onTap,
  });

  @override
  State<_WebOptimizedCard> createState() => _WebOptimizedCardState();
}

class _WebOptimizedCardState extends State<_WebOptimizedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _borderColorAnimation = ColorTween(
      begin: AppColors.borderLight,
      end: AppColors.primary.withValues(alpha: 0.4),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _borderColorAnimation.value ?? AppColors.borderLight,
                  width: _isHovered ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isHovered ? 0.08 : 0.04,
                    ),
                    blurRadius: _isHovered ? 20 : 12,
                    offset: Offset(0, _elevationAnimation.value),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

class _SubTaskItem extends StatefulWidget {
  final SubTask subTask;
  final VoidCallback? onComplete;

  const _SubTaskItem({
    required this.subTask,
    this.onComplete,
  });

  @override
  State<_SubTaskItem> createState() => _SubTaskItemState();
}

class _SubTaskItemState extends State<_SubTaskItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.subTask.status == WorkStepStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: isCompleted ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered && !isCompleted
                ? AppColors.hoverBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Web-optimized checkbox with larger hit area
              SizedBox(
                width: 44,
                height: 44,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: isCompleted ? null : (_) => widget.onComplete?.call(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.subTask.name,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ),
              if (widget.subTask.assignedToActorId != null)
                FutureBuilder<Actor>(
                  future: context.read<IActorService>().getActor(widget.subTask.assignedToActorId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final actor = snapshot.data!;
                      return Container(
                        margin: const EdgeInsets.only(left: 12),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            actor.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
