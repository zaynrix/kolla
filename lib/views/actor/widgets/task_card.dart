import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/work_step.dart';
import '../../../models/task.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';
import '../../../services/interfaces/i_task_service.dart';
import '../../shared/widgets/priority_badge.dart';
import '../../shared/widgets/jira_task_card.dart';

/// Modern task card for actor page
/// Single Responsibility: Display a single work step/task
class TaskCard extends StatefulWidget {
  final WorkStep workStep;
  final Task task;
  final VoidCallback? onComplete;

  const TaskCard({
    super.key,
    required this.workStep,
    required this.task,
    this.onComplete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Use Jira-style card if task has subtasks, otherwise use modern card
    if (widget.task.subTasks.isNotEmpty) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Transform.scale(
            scale: _isHovered ? 1.02 : 1.0,
            child: JiraTaskCard(
              task: widget.task,
              workStep: widget.workStep,
              onTap: () {},
              onSubTaskComplete: (subTask) async {
                try {
                  await context.read<ITaskService>().completeSubTask(subTask.id);
                } catch (e) {
                  // Error handling
                }
              },
            ),
          ),
        ),
      );
    }

    final remainingSteps = widget.task.workSteps
        .where((ws) =>
            ws.sequenceOrder > widget.workStep.sequenceOrder &&
            ws.status != WorkStepStatus.completed)
        .length;

    final priority = widget.workStep.getEffectivePriority(
      widget.task.deadline,
      remainingSteps,
    );
    final hoursUntilDeadline =
        widget.task.deadline.difference(DateTime.now()).inHours;

    final isUrgent = hoursUntilDeadline < 24 && hoursUntilDeadline >= 0;
    final isOverdue = hoursUntilDeadline < 0;
    final isCompleted = widget.workStep.status == WorkStepStatus.completed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        child: Transform.scale(
          scale: _isHovered ? 1.01 : 1.0,
          child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.borderLight,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  _isHovered ? 0.1 : 0.05,
                ),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 6 : 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
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
                              Text(
                                widget.task.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      color: isCompleted
                                          ? AppColors.textTertiary
                                          : AppColors.textPrimary,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.workStep.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: isCompleted
                                          ? AppColors.textTertiary
                                          : AppColors.textSecondary,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        PriorityBadge(priority: priority),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Meta Information
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetaChip(
                          icon: Icons.badge_outlined,
                          label: widget.workStep.role,
                          color: AppColors.primary,
                        ),
                        _MetaChip(
                          icon: Icons.access_time_rounded,
                          label: '${widget.workStep.durationHours}h',
                          color: AppColors.textSecondary,
                        ),
                        if (isOverdue)
                          const _MetaChip(
                            icon: Icons.warning_rounded,
                            label: 'OVERDUE',
                            color: AppColors.overdue,
                            isUrgent: true,
                          )
                        else if (isUrgent)
                          const _MetaChip(
                            icon: Icons.priority_high_rounded,
                            label: 'URGENT',
                            color: AppColors.warning,
                            isUrgent: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.task.progressPercentage / 100,
                              minHeight: 8,
                              backgroundColor: AppColors.backgroundLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.task.status == TaskStatus.overdue
                                    ? AppColors.overdue
                                    : widget.task.status == TaskStatus.atRisk
                                        ? AppColors.atRisk
                                        : AppColors.onTrack,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.task.progressPercentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),

                    // Complete Button
                    if (widget.onComplete != null &&
                        widget.workStep.status == WorkStepStatus.pending) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onComplete,
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          label: const Text(
                            AppStrings.complete,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// Modern Meta Chip
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isUrgent;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent
            ? color.withOpacity(0.15)
            : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: isUrgent
            ? Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
