import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/actor_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../shared/layouts/jira_layout.dart';
import 'widgets/task_list_view.dart';
import 'widgets/create_task_dialog.dart';
import '../../views/workflow_manager/widgets/draggable_kanban_board.dart';
import '../../views/workflow_manager/widgets/modern_task_detail_dialog.dart';
import '../../../models/work_step.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;

class ActorPage extends StatelessWidget {
  final String actorId;

  const ActorPage({required this.actorId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActorController(
        taskService: context.read<ITaskService>(),
        actorId: actorId,
      ),
      child: Consumer<ActorController>(
        builder: (context, controller, _) {
          return JiraLayout(
            title: AppStrings.myTasks,
            actions: [
              _ModernViewModeButton(
                icon: Icons.view_list_rounded,
                isActive: controller.viewMode == ViewMode.list,
                onPressed: controller.viewMode == ViewMode.list
                    ? null
                    : controller.toggleViewMode,
                tooltip: 'List View',
              ),
              const SizedBox(width: 8),
              _ModernViewModeButton(
                icon: Icons.bar_chart_rounded,
                isActive: controller.viewMode == ViewMode.chart,
                onPressed: controller.viewMode == ViewMode.chart
                    ? null
                    : controller.toggleViewMode,
                tooltip: 'Kanban View',
              ),
              const SizedBox(width: 8),
              _ModernActionButton(
                icon: Icons.refresh_rounded,
                onPressed: controller.refresh,
                tooltip: AppStrings.refresh,
              ),
              const SizedBox(width: 8),
              _ModernCreateButton(
                onPressed: () => _showCreateTaskDialog(context, controller),
                tooltip: 'Create New Task',
              ),
            ],
            child: _buildBody(controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(ActorController controller) {
    if (controller.isLoading) {
      return const LoadingWidget(showSkeleton: true);
    }

    if (controller.error != null) {
      return custom.ErrorWidget(
        error: controller.error!,
        onRetry: controller.refresh,
      );
    }

    if (controller.workSteps.isEmpty) {
      return Center(
        child: _ModernEmptyState(
          message: AppStrings.noTasks,
          icon: Icons.task_alt_rounded,
        ),
      );
    }

    if (controller.viewMode == ViewMode.list) {
      return Container(
        color: AppColors.backgroundLight,
        padding: const EdgeInsets.all(24),
        child: TaskListView(controller: controller),
      );
    } else {
      // Show Kanban board for actor's tasks
      return _ActorKanbanView(controller: controller);
    }
  }
  
  void _showCreateTaskDialog(BuildContext context, ActorController controller) {
    final actorService = context.read<IActorService>();
    
    actorService.getActor(controller.actorId).then((actor) {
      showDialog(
        context: context,
        builder: (context) => CreateTaskDialog(
          actorId: controller.actorId,
          actorRole: actor.role,
          onCreateTask: (task) {
            controller.createTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Task "${task.name}" created successfully!'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
        ),
      );
    });
  }
}

// Actor-specific Kanban view
class _ActorKanbanView extends StatelessWidget {
  final ActorController controller;

  const _ActorKanbanView({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Get all tasks that have work steps assigned to this actor
    final actorTasks = controller.allTasks.where((task) {
      return task.workSteps.any((ws) => ws.assignedToActorId == controller.actorId);
    }).toList();

    if (actorTasks.isEmpty) {
      return Center(
        child: _ModernEmptyState(
          message: 'No tasks assigned to you yet',
          icon: Icons.assignment_outlined,
        ),
      );
    }

    return Container(
      color: AppColors.backgroundLight,
      child: DraggableKanbanBoard(
        tasks: actorTasks,
        onCardTap: (workStep) {
          _showTaskDetailDialog(context, workStep, controller);
        },
        onStatusChange: (workStep, newStatus) {
          controller.updateWorkStepStatus(workStep.id, newStatus);
        },
      ),
    );
  }

  void _showTaskDetailDialog(
    BuildContext context,
    WorkStep workStep,
    ActorController controller,
  ) {
    final task = controller.getTaskForWorkStep(workStep);
    showDialog(
      context: context,
      builder: (context) => ModernTaskDetailDialog(
        task: task,
        workStep: workStep,
      ),
    );
  }
}

// Modern View Mode Button
class _ModernViewModeButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ModernViewModeButton({
    required this.icon,
    required this.isActive,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_ModernViewModeButton> createState() => _ModernViewModeButtonState();
}

class _ModernViewModeButtonState extends State<_ModernViewModeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : _isHovered
                        ? AppColors.hoverBackground
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isActive
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Action Button
class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ModernActionButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.onPressed != null
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Create Button
class _ModernCreateButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String tooltip;

  const _ModernCreateButton({
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_ModernCreateButton> createState() => _ModernCreateButtonState();
}

class _ModernCreateButtonState extends State<_ModernCreateButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Empty State
class _ModernEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _ModernEmptyState({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 72,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          message,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create your first task to get started',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
