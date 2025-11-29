import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';

class TaskTrackingCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onPriorityOverride;

  const TaskTrackingCard({
    super.key,
    required this.task,
    this.onPriorityOverride,
  });

  @override
  Widget build(BuildContext context) {
    final hoursUntilDeadline = task.deadline.difference(DateTime.now()).inHours;
    final statusColor = task.status == TaskStatus.overdue
        ? AppColors.overdue
        : task.status == TaskStatus.atRisk
            ? AppColors.atRisk
            : AppColors.onTrack;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    _getStatusLabel(task.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDeadline(task.deadline, hoursUntilDeadline),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hoursUntilDeadline < 24
                            ? AppColors.warning
                            : Colors.grey[700],
                      ),
                ),
                const Spacer(),
                Text(
                  '${task.completedStepsCount}/${task.workSteps.length} steps',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: task.progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${task.progressPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.workSteps
                  .where((ws) => ws.status == WorkStepStatus.pending)
                  .map((ws) => Chip(
                        label: Text(ws.name),
                        avatar: CircleAvatar(
                          backgroundColor: _getPriorityColor(ws, task)
                              .withValues(alpha: 0.2),
                          child: Icon(
                            Icons.work,
                            size: 16,
                            color: _getPriorityColor(ws, task),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.onTrack:
        return AppStrings.onTrack;
      case TaskStatus.atRisk:
        return AppStrings.atRisk;
      case TaskStatus.overdue:
        return AppStrings.overdue;
    }
  }

  String _formatDeadline(DateTime deadline, int hoursUntilDeadline) {
    if (hoursUntilDeadline < 0) {
      return 'Overdue by ${(-hoursUntilDeadline / 24).toStringAsFixed(0)} days';
    } else if (hoursUntilDeadline < 24) {
      return 'Due in $hoursUntilDeadline hours';
    } else {
      return 'Due in ${(hoursUntilDeadline / 24).toStringAsFixed(0)} days';
    }
  }

  Color _getPriorityColor(workStep, task) {
    final remainingSteps = task.workSteps
        .where((ws) =>
            ws.sequenceOrder > workStep.sequenceOrder &&
            ws.status != WorkStepStatus.completed)
        .length;
    final priority = workStep.getEffectivePriority(task.deadline, remainingSteps);
    switch (priority) {
      case Priority.immediate:
        return AppColors.immediatePriority;
      case Priority.medium:
        return AppColors.mediumPriority;
      case Priority.longTerm:
        return AppColors.longTermPriority;
      default:
        return AppColors.mediumPriority;
    }
  }
}

