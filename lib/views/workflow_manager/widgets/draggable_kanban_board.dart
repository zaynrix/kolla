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

/// Trello-style Kanban Board
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

    // Trello-style background
    return Container(
      color: const Color(0xFF0079BF), // Trello blue background
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TrelloColumn(
              title: 'To Do',
              count: pendingSteps.length,
              status: WorkStepStatus.pending,
              tasks: tasks,
              workSteps: pendingSteps,
              onCardTap: onCardTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TrelloColumn(
              title: 'In Progress',
              count: inProgressSteps.length,
              status: WorkStepStatus.inProgress,
              tasks: tasks,
              workSteps: inProgressSteps,
              onCardTap: onCardTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TrelloColumn(
              title: 'Done',
              count: completedSteps.length,
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

/// Trello-style column
class _TrelloColumn extends StatelessWidget {
  final String title;
  final int count;
  final WorkStepStatus status;
  final List<Task> tasks;
  final List<WorkStep> workSteps;
  final Function(WorkStep)? onCardTap;
  final Function(WorkStep, WorkStepStatus)? onStatusChange;

  const _TrelloColumn({
    required this.title,
    required this.count,
    required this.status,
    required this.tasks,
    required this.workSteps,
    this.onCardTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KanbanColumnController(),
      child: Consumer<KanbanColumnController>(
        builder: (context, columnController, _) {
          return DragTarget<WorkStep>(
            onAccept: (draggedWorkStep) {
              if (onStatusChange != null && draggedWorkStep.status != status) {
                onStatusChange!(draggedWorkStep, status);
              }
            },
            builder: (context, candidateData, rejectedData) {
              final isTargeted = candidateData.isNotEmpty;
              
              return MouseRegion(
                onEnter: (_) => columnController.setHovered(true),
                onExit: (_) => columnController.setHovered(false),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBECF0), // Trello column background
                    borderRadius: BorderRadius.circular(8),
                    border: isTargeted
                        ? Border.all(
                            color: const Color(0xFF0079BF),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column Header - Trello style
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF172B4D),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFE1E6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5E6C84),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Cards List
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              ...workSteps.map((workStep) {
                                final task = tasks.firstWhereOrNull(
                                  (t) => t.id == workStep.taskId,
                                );
                                
                                if (task == null) {
                                  return const SizedBox.shrink();
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _DraggableCard(
                                    workStep: workStep,
                                    task: task,
                                    currentStatus: status,
                                    onTap: onCardTap != null
                                        ? () => onCardTap!(workStep)
                                        : null,
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Trello-style draggable card
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
        elevation: 8,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 272,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _CardContent(task: task, workStep: workStep),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TrelloCard(
          task: task,
          workStep: workStep,
          onTap: onTap,
        ),
      ),
      child: _TrelloCard(
        task: task,
        workStep: workStep,
        onTap: onTap,
      ),
    );
  }
}

/// Trello-style card content
class _CardContent extends StatelessWidget {
  final Task task;
  final WorkStep workStep;

  const _CardContent({
    required this.task,
    required this.workStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          task.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF172B4D),
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (workStep.name != task.name) ...[
          const SizedBox(height: 6),
          Text(
            workStep.name,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5E6C84),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Trello-style card widget
class _TrelloCard extends StatefulWidget {
  final Task task;
  final WorkStep workStep;
  final VoidCallback? onTap;

  const _TrelloCard({
    required this.task,
    required this.workStep,
    this.onTap,
  });

  @override
  State<_TrelloCard> createState() => _TrelloCardState();
}

class _TrelloCardState extends State<_TrelloCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: _CardContent(
            task: widget.task,
            workStep: widget.workStep,
          ),
        ),
      ),
    );
  }
}
