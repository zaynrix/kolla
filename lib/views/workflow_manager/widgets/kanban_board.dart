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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _KanbanColumn(
              title: 'To Do',
              count: pendingSteps.length,
              color: AppColors.textSecondary,
              tasks: tasks,
              workSteps: pendingSteps,
              onCardTap: onCardTap,
              onStatusChange: onStatusChange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _KanbanColumn(
              title: 'In Progress',
              count: inProgressSteps.length,
              color: AppColors.mediumPriority,
              tasks: tasks,
              workSteps: inProgressSteps,
              onCardTap: onCardTap,
              onStatusChange: onStatusChange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _KanbanColumn(
              title: 'Done',
              count: completedSteps.length,
              color: AppColors.success,
              tasks: tasks,
              workSteps: completedSteps,
              onCardTap: onCardTap,
              onStatusChange: onStatusChange,
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Jira/Trello style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cards - Scrollable
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minHeight: 200),
              child: workSteps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppColors.textTertiary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No items',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: workSteps.length,
                      itemBuilder: (context, index) {
                        final workStep = workSteps[index];
                        final task = tasks.firstWhere((t) => t.id == workStep.taskId);
                        return TrelloCard(
                          workStep: workStep,
                          task: task,
                          onTap: () => onCardTap?.call(workStep),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
