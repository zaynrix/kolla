import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/subtask.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_task_service.dart';

class TaskDetailDialog extends StatelessWidget {
  final Task task;
  final WorkStep? workStep;
  final Function(Task)? onUpdate;

  const TaskDetailDialog({
    super.key,
    required this.task,
    this.workStep,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Task Info
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.calendar_today,
                    label: 'Deadline',
                    value: _formatDeadline(task.deadline),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.trending_up,
                    label: 'Progress',
                    value: '${task.progressPercentage.toStringAsFixed(0)}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.assignment,
                    label: 'Status',
                    value: _getStatusText(task.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Subtasks
            if (task.subTasks.isNotEmpty) ...[
              Text(
                'Subtasks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: task.subTasks.length,
                  itemBuilder: (context, index) {
                    final subTask = task.subTasks[index];
                    return _SubTaskItem(
                      subTask: subTask,
                      onComplete: () async {
                        final taskService = context.read<ITaskService>();
                        await taskService.completeSubTask(subTask.id);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Work Steps
            Text(
              'Work Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: task.workSteps.length,
                itemBuilder: (context, index) {
                  final step = task.workSteps[index];
                  return _WorkStepItem(
                    workStep: step,
                    onStatusChange: (newStatus) async {
                      final taskService = context.read<ITaskService>();
                      await taskService.updateWorkStepStatus(step.id, newStatus);
                    },
                  );
                },
              ),
            ),
            
            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Edit task
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.inDays > 0) {
      return '${diff.inDays}d left';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h left';
    } else {
      return 'Overdue';
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.onTrack:
        return 'On Track';
      case TaskStatus.atRisk:
        return 'At Risk';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SubTaskItem extends StatelessWidget {
  final SubTask subTask;
  final VoidCallback? onComplete;

  const _SubTaskItem({
    required this.subTask,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = subTask.status == WorkStepStatus.completed;
    return ListTile(
      leading: Checkbox(
        value: isCompleted,
        onChanged: isCompleted ? null : (_) => onComplete?.call(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        activeColor: AppColors.primary,
      ),
      title: Text(
        subTask.name,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _WorkStepItem extends StatelessWidget {
  final WorkStep workStep;
  final Function(WorkStepStatus)? onStatusChange;

  const _WorkStepItem({
    required this.workStep,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workStep.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workStep.role,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${workStep.durationHours}h',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DropdownButton<WorkStepStatus>(
            value: workStep.status,
            items: WorkStepStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusLabel(status)),
              );
            }).toList(),
            onChanged: (newStatus) {
              if (newStatus != null && newStatus != workStep.status) {
                onStatusChange?.call(newStatus);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(WorkStepStatus status) {
    switch (status) {
      case WorkStepStatus.pending:
        return 'To Do';
      case WorkStepStatus.inProgress:
        return 'In Progress';
      case WorkStepStatus.completed:
        return 'Done';
    }
  }
}

