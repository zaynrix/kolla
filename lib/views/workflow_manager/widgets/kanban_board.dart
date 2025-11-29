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
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _WebOptimizedColumn(
              title: 'To Do',
              count: pendingSteps.length,
              color: AppColors.textSecondary,
              tasks: tasks,
              workSteps: pendingSteps,
              onCardTap: onCardTap,
              onStatusChange: onStatusChange,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _WebOptimizedColumn(
              title: 'In Progress',
              count: inProgressSteps.length,
              color: AppColors.mediumPriority,
              tasks: tasks,
              workSteps: inProgressSteps,
              onCardTap: onCardTap,
              onStatusChange: onStatusChange,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _WebOptimizedColumn(
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

// Web-optimized column with hover effects
class _WebOptimizedColumn extends StatefulWidget {
  final String title;
  final int count;
  final Color color;
  final List<Task> tasks;
  final List<WorkStep> workSteps;
  final Function(WorkStep)? onCardTap;
  final Function(WorkStep, WorkStepStatus)? onStatusChange;

  const _WebOptimizedColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.tasks,
    required this.workSteps,
    this.onCardTap,
    this.onStatusChange,
  });

  @override
  State<_WebOptimizedColumn> createState() => _WebOptimizedColumnState();
}

class _WebOptimizedColumnState extends State<_WebOptimizedColumn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.3)
                : widget.color.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(
                alpha: _isHovered ? 0.08 : 0.05,
              ),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Jira/Trello style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withValues(alpha: 0.15),
                    widget.color.withValues(alpha: 0.08),
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
                      color: widget.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.color,
                            letterSpacing: 0.8,
                            fontSize: 12,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.count.toString(),
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
            // Cards - Scrollable
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                constraints: const BoxConstraints(minHeight: 200),
                child: widget.workSteps.isEmpty
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
                              'No items',
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
                        itemCount: widget.workSteps.length,
                        itemBuilder: (context, index) {
                          final workStep = widget.workSteps[index];
                          final task = widget.tasks.firstWhere((t) => t.id == workStep.taskId);
                          return TrelloCard(
                            workStep: workStep,
                            task: task,
                            onTap: () => widget.onCardTap?.call(workStep),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
