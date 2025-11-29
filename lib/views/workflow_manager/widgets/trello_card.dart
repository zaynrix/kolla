import 'package:flutter/material.dart';
import '../../../models/work_step.dart';
import '../../../models/task.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../shared/widgets/priority_badge.dart';

class TrelloCard extends StatelessWidget {
  final WorkStep workStep;
  final Task task;
  final VoidCallback? onTap;

  const TrelloCard({
    super.key,
    required this.workStep,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remainingSteps = task.workSteps
        .where((ws) =>
            ws.sequenceOrder > workStep.sequenceOrder &&
            ws.status != WorkStepStatus.completed)
        .length;

    final priority = workStep.getEffectivePriority(task.deadline, remainingSteps);
    final hoursUntilDeadline = task.deadline.difference(DateTime.now()).inHours;
    final isUrgent = hoursUntilDeadline < 24 && hoursUntilDeadline >= 0;
    final isOverdue = hoursUntilDeadline < 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? AppColors.overdue
                  : isUrgent
                      ? AppColors.warning
                      : AppColors.primary.withValues(alpha: 0.1),
              width: isOverdue || isUrgent ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isOverdue
                        ? AppColors.overdue
                        : isUrgent
                            ? AppColors.warning
                            : AppColors.primary)
                    .withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriorityBadge(priority: priority),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.overdue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: AppColors.overdue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Task name
              Text(
                task.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Work step name
              Text(
                workStep.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progressPercentage / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
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
                  const SizedBox(width: 8),
                  Text(
                    '${task.progressPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Footer with metadata
              Row(
                children: [
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      workStep.role,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const Spacer(),
                  // Time info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isOverdue
                            ? AppColors.overdue
                            : isUrgent
                                ? AppColors.warning
                                : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(hoursUntilDeadline),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOverdue
                                  ? AppColors.overdue
                                  : isUrgent
                                      ? AppColors.warning
                                      : AppColors.textTertiary,
                              fontWeight: isOverdue || isUrgent
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int hours) {
    if (hours < 0) {
      return '${(-hours / 24).toStringAsFixed(0)}d overdue';
    } else if (hours < 24) {
      return '${hours}h left';
    } else {
      return '${(hours / 24).toStringAsFixed(0)}d left';
    }
  }
}

