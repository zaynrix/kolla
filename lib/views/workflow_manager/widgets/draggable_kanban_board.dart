import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_task_service.dart';
import '../../../utils/extensions.dart';
import '../../../controllers/kanban_column_controller.dart';
import 'trello_card.dart';

class DraggableKanbanBoard extends StatelessWidget {
  final List<Task> tasks;
  final Function(WorkStep, WorkStepStatus)? onStatusChange;
  final Function(WorkStep)? onCardTap;

  const DraggableKanbanBoard({
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
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _DraggableColumn(
              title: 'To Do',
              count: pendingSteps.length,
              color: AppColors.textSecondary,
              status: WorkStepStatus.pending,
              tasks: tasks,
              workSteps: pendingSteps,
              onCardTap: onCardTap,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _DraggableColumn(
              title: 'In Progress',
              count: inProgressSteps.length,
              color: AppColors.mediumPriority,
              status: WorkStepStatus.inProgress,
              tasks: tasks,
              workSteps: inProgressSteps,
              onCardTap: onCardTap,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _DraggableColumn(
              title: 'Done',
              count: completedSteps.length,
              color: AppColors.success,
              status: WorkStepStatus.completed,
              tasks: tasks,
              workSteps: completedSteps,
              onCardTap: onCardTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final WorkStepStatus status;
  final List<Task> tasks;
  final List<WorkStep> workSteps;
  final Function(WorkStep)? onCardTap;

  const _DraggableColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.status,
    required this.tasks,
    required this.workSteps,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return _WebOptimizedColumn(
      color: color,
      title: title,
      count: count,
      tasks: tasks,
      workSteps: workSteps,
      status: status,
      onCardTap: onCardTap,
    );
  }
}

// Web-optimized column with drag and drop
class _WebOptimizedColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final WorkStepStatus status;
  final List<Task> tasks;
  final List<WorkStep> workSteps;
  final Function(WorkStep)? onCardTap;

  const _WebOptimizedColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.status,
    required this.tasks,
    required this.workSteps,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KanbanColumnController(),
      child: Consumer<KanbanColumnController>(
        builder: (context, columnController, _) {
          return MouseRegion(
            onEnter: (_) => columnController.setHovered(true),
            onExit: (_) => columnController.setHovered(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: columnController.isHovered
                      ? color.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.2),
                  width: columnController.isHovered ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(
                      alpha: columnController.isHovered ? 0.08 : 0.05,
                    ),
                    blurRadius: columnController.isHovered ? 16 : 10,
                    offset: Offset(0, columnController.isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title.toUpperCase(),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                  letterSpacing: 0.8,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cards - Scrollable with Drag & Drop
                  Flexible(
                    child: DragTarget<WorkStep>(
                      onAcceptWithDetails: (details) {
                        // Update work step status when dropped
                        final workStep = details.data;
                        if (workStep.status != status) {
                          final taskService = context.read<ITaskService>();
                          taskService.updateWorkStepStatus(workStep.id, status);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isTargeted = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(minHeight: 200),
                          decoration: isTargeted
                              ? BoxDecoration(
                                  color: color.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(18),
                                )
                              : null,
                          child: workSteps.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 56,
                                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Drop tasks here',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textTertiary,
                                              fontWeight: FontWeight.w500,
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
                                    final task = tasks.firstWhereOrNull((t) => t.id == workStep.taskId);
                                    if (task == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return _DraggableCard(
                                      workStep: workStep,
                                      task: task,
                                      currentStatus: status,
                                      onTap: () => onCardTap?.call(workStep),
                                    );
                                  },
                                ),
                        );
                      },
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

// Draggable card widget - Trello style
class _DraggableCard extends StatelessWidget {
  final WorkStep workStep;
  final Task task;
  final WorkStepStatus currentStatus;
  final VoidCallback? onTap;

  const _DraggableCard({
    required this.workStep,
    required this.task,
    required this.currentStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<WorkStep>(
      data: workStep,
      feedback: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                workStep.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: TrelloCard(
          workStep: workStep,
          task: task,
          onTap: onTap,
        ),
      ),
      child: TrelloCard(
        workStep: workStep,
        task: task,
        onTap: onTap,
      ),
    );
  }
}
