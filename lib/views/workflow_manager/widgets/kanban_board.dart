import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import 'trello_card.dart';

class KanbanBoard extends StatelessWidget {
  final List<Task> tasks;
  final Function(WorkStep, WorkStepStatus)? onStatusChange;
  final Function(WorkStep)? onCardTap;

  const KanbanBoard({
    super.key,
    required this.tasks,
    this.onStatusChange,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group work steps by status
    final pendingSteps = <WorkStep>[];
    final inProgressSteps = <WorkStep>[];
    final completedSteps = <WorkStep>[];

    for (var task in tasks) {
      for (var step in task.workSteps) {
        switch (step.status) {
          case WorkStepStatus.pending:
            pendingSteps.add(step);
            break;
          case WorkStepStatus.inProgress:
            inProgressSteps.add(step);
            break;
          case WorkStepStatus.completed:
            completedSteps.add(step);
            break;
        }
      }
    }

    return Container(
      color: AppColors.backgroundLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KanbanColumn(
            title: 'To Do',
            count: pendingSteps.length,
            color: AppColors.textSecondary,
            tasks: tasks,
            workSteps: pendingSteps,
            onCardTap: onCardTap,
            onStatusChange: onStatusChange,
          ),
          _KanbanColumn(
            title: 'In Progress',
            count: inProgressSteps.length,
            color: AppColors.mediumPriority,
            tasks: tasks,
            workSteps: inProgressSteps,
            onCardTap: onCardTap,
            onStatusChange: onStatusChange,
          ),
          _KanbanColumn(
            title: 'Done',
            count: completedSteps.length,
            color: AppColors.success,
            tasks: tasks,
            workSteps: completedSteps,
            onCardTap: onCardTap,
            onStatusChange: onStatusChange,
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<Task> tasks;
  final List<WorkStep> workSteps;
  final Function(WorkStep)? onCardTap;
  final Function(WorkStep, WorkStepStatus)? onStatusChange;

  const _KanbanColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.tasks,
    required this.workSteps,
    this.onCardTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Cards
            Expanded(
              child: workSteps.isEmpty
                  ? Center(
                      child: Text(
                        'No items',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade400,
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: workSteps.length,
                      itemBuilder: (context, index) {
                        final step = workSteps[index];
                        final task = tasks.firstWhere((t) => t.id == step.taskId);
                        return TrelloCard(
                          workStep: step,
                          task: task,
                          onTap: () => onCardTap?.call(step),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

