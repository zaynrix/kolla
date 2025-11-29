import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/actor_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../shared/layouts/jira_layout.dart';
import 'widgets/task_list_view.dart';
import 'widgets/task_chart_view.dart';
import 'widgets/create_task_dialog.dart';
import '../../views/workflow_manager/widgets/draggable_kanban_board.dart';
import '../../views/workflow_manager/widgets/task_detail_dialog.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;
import '../shared/widgets/empty_state_widget.dart';

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
              _WebViewModeButton(
                icon: Icons.view_list,
                isActive: controller.viewMode == ViewMode.list,
                onPressed: controller.viewMode == ViewMode.list
                    ? null
                    : controller.toggleViewMode,
                tooltip: 'List View',
              ),
              const SizedBox(width: 8),
              _WebViewModeButton(
                icon: Icons.bar_chart,
                isActive: controller.viewMode == ViewMode.chart,
                onPressed: controller.viewMode == ViewMode.chart
                    ? null
                    : controller.toggleViewMode,
                tooltip: 'Chart View',
              ),
              const SizedBox(width: 8),
              _WebActionButton(
                icon: Icons.refresh,
                onPressed: controller.refresh,
                tooltip: AppStrings.refresh,
              ),
              const SizedBox(width: 8),
              _WebCreateButton(
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
      return const EmptyStateWidget(
        message: AppStrings.noTasks,
        icon: Icons.task_alt,
      );
    }

    if (controller.viewMode == ViewMode.list) {
      return TaskListView(controller: controller);
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
                content: Text('Task "${task.name}" created successfully!'),
                backgroundColor: AppColors.success,
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
      return const Center(
        child: Text('No tasks assigned'),
      );
    }

    return DraggableKanbanBoard(
      tasks: actorTasks,
      onCardTap: (workStep) {
        _showTaskDetailDialog(context, workStep, controller);
      },
      onStatusChange: (workStep, newStatus) {
        controller.updateWorkStepStatus(workStep.id, newStatus);
      },
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
      builder: (context) => TaskDetailDialog(
        task: task,
        workStep: workStep,
        onUpdate: (updatedTask) {
          // Handle task update if needed
        },
      ),
    );
  }
}

// Web-optimized view mode button
class _WebViewModeButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onPressed;
  final String tooltip;

  const _WebViewModeButton({
    required this.icon,
    required this.isActive,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_WebViewModeButton> createState() => _WebViewModeButtonState();
}

class _WebViewModeButtonState extends State<_WebViewModeButton> {
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
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : _isHovered
                        ? AppColors.hoverBackground
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
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

// Web-optimized action button
class _WebActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _WebActionButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_WebActionButton> createState() => _WebActionButtonState();
}

class _WebActionButtonState extends State<_WebActionButton> {
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
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.hoverBackground,
                borderRadius: BorderRadius.circular(10),
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

// Web-optimized create button
class _WebCreateButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String tooltip;

  const _WebCreateButton({
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_WebCreateButton> createState() => _WebCreateButtonState();
}

class _WebCreateButtonState extends State<_WebCreateButton> {
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
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.add,
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

