import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/actor_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../services/interfaces/i_notification_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../shared/layouts/jira_layout.dart';
import 'widgets/task_list_view.dart';
import 'widgets/create_task_dialog.dart';
import '../../views/workflow_manager/widgets/draggable_kanban_board.dart';
import '../../views/workflow_manager/widgets/task_detail/modern_task_detail_dialog.dart';
import '../../../models/work_step.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;
import 'widgets/actor_header_section.dart';
import 'widgets/view_mode_selector.dart';

class ActorPage extends StatelessWidget {
  final String actorId;

  const ActorPage({required this.actorId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActorController(
        taskService: context.read<ITaskService>(),
        notificationService: context.read<INotificationService>(),
        actorId: actorId,
      ),
      child: Consumer<ActorController>(
        builder: (context, controller, _) {
          return JiraLayout(
            title: AppStrings.myTasks,
            actions: [
              ViewModeSelector(
                currentMode: controller.viewMode,
                onModeChanged: controller.toggleViewMode,
              ),
              const SizedBox(width: 12),
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
            child: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ActorController controller) {
    if (controller.isLoading) {
      return const LoadingWidget(showSkeleton: true);
    }

    if (controller.error != null) {
      return custom.ErrorWidget(
        error: controller.error!,
        onRetry: controller.refresh,
      );
    }

    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Modern Header Section with Stats
          ActorHeaderSection(controller: controller),
          
          // Main Content Area
          Expanded(
            child: controller.workSteps.isEmpty
                ? _ModernEmptyState(
                    message: AppStrings.noTasks,
                    icon: Icons.task_alt_rounded,
                    onCreateTask: () => _showCreateTaskDialog(context, controller),
                  )
                : controller.viewMode == ViewMode.list
                    ? _ModernListView(controller: controller)
                    : _ActorKanbanView(controller: controller),
          ),
        ],
      ),
    );
  }
  
  void _showCreateTaskDialog(BuildContext context, ActorController controller) {
    final actorService = context.read<IActorService>();
    
    actorService.getActor(controller.actorId).then((actor) {
      if (!context.mounted) return;
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
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Task "${task.name}" created successfully!',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      );
    });
  }
}

// Modern List View with better spacing
class _ModernListView extends StatelessWidget {
  final ActorController controller;

  const _ModernListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: TaskListView(controller: controller),
    );
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
      return const _ModernEmptyState(
        message: 'No tasks assigned to you yet',
        icon: Icons.assignment_outlined,
        onCreateTask: null,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'New Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
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
  final VoidCallback? onCreateTask;

  const _ModernEmptyState({
    required this.message,
    required this.icon,
    this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              onCreateTask != null
                  ? 'Get started by creating your first task'
                  : 'Tasks will appear here once assigned',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onCreateTask != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onCreateTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Task'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
