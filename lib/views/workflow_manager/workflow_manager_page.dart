import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../services/interfaces/i_notification_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../../models/work_step.dart';
import '../../utils/extensions.dart';
import '../shared/layouts/jira_layout.dart';
import 'widgets/draggable_kanban_board.dart';
import 'widgets/task_detail/modern_task_detail_dialog.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;
import 'widgets/workflow_header_section.dart';
import 'widgets/search_and_filters_bar.dart';

class WorkflowManagerPage extends StatelessWidget {
  const WorkflowManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkflowManagerController(
        taskService: context.read<ITaskService>(),
        actorService: context.read<IActorService>(),
        notificationService: context.read<INotificationService>(),
      ),
      child: Consumer<WorkflowManagerController>(
        builder: (context, controller, _) {
          return JiraLayout(
            title: AppStrings.workflowManager,
            actions: [
              _ModernActionButton(
                icon: Icons.refresh_rounded,
                onPressed: controller.refresh,
                tooltip: AppStrings.refresh,
              ),
            ],
            child: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WorkflowManagerController controller,
  ) {
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
          WorkflowHeaderSection(controller: controller),
          
          // Search and Filters Bar
          SearchAndFiltersBar(controller: controller),
          
          // Kanban Board
          Expanded(
            child: controller.filteredTasks.isEmpty
                ? _ModernEmptyState(
                    message: 'No tasks found',
                    icon: Icons.task_alt_rounded,
                    hasFilters: controller.filter != TaskFilter.all ||
                        controller.searchQuery.isNotEmpty,
                  )
                : Container(
                    color: AppColors.backgroundLight,
                    child: DraggableKanbanBoard(
                      tasks: controller.filteredTasks,
                      onCardTap: (workStep) {
                        _showTaskDetailDialog(context, workStep, controller);
                      },
                      onStatusChange: (workStep, newStatus) {
                        controller.updateWorkStepStatus(workStep.id, newStatus);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailDialog(
    BuildContext context,
    WorkStep workStep,
    WorkflowManagerController controller,
  ) {
    final task = controller.allTasks.firstWhereOrNull((t) => t.id == workStep.taskId) ??
        controller.filteredTasks.firstWhereOrNull((t) => t.id == workStep.taskId);
    
    if (task == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Task not found',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    
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
                    ? AppColors.primary.withOpacity(0.1)
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

// Modern Empty State
class _ModernEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool hasFilters;

  const _ModernEmptyState({
    required this.message,
    required this.icon,
    this.hasFilters = false,
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
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
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
              hasFilters
                  ? 'Try adjusting your filters or search query'
                  : 'Tasks will appear here once created',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
