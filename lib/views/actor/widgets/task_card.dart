import 'package:flutter/material.dart';
import '../../../models/work_step.dart';
import '../../../models/task.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';
import '../../../utils/animations.dart';
import '../../shared/widgets/priority_badge.dart';

class TaskCard extends StatelessWidget {
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

    return ModernCard(
      onTap: () {},
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      backgroundColor: null, // Use theme default
      borderRadius: BorderRadius.circular(20),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PriorityBadge(priority: priority),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workStep.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workStep.role,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${workStep.durationHours}h',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const Spacer(),
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
                      )
                    else if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'URGENT',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
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
                    const SizedBox(width: 12),
                    Text(
                      '${task.progressPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (onComplete != null && workStep.status == WorkStepStatus.pending) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text(
                        AppStrings.complete,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

