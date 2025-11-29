import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../../utils/extensions.dart';
import '../shared/layouts/jira_layout.dart';
import '../workflow_manager/widgets/draggable_kanban_board.dart';
import '../workflow_manager/widgets/modern_task_detail_dialog.dart';
import '../../models/work_step.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;

class AllBoardsPage extends StatelessWidget {
  const AllBoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkflowManagerController(
        taskService: context.read<ITaskService>(),
        actorService: context.read<IActorService>(),
      ),
      child: Consumer<WorkflowManagerController>(
        builder: (context, controller, _) {
          return JiraLayout(
            title: 'All Boards',
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
      return const LoadingWidget();
    }

    if (controller.error != null) {
      return custom.ErrorWidget(
        error: controller.error!,
        onRetry: controller.refresh,
      );
    }

    return Container(
      color: AppColors.backgroundLight,
      child: DraggableKanbanBoard(
        tasks: controller.allTasks,
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
    WorkflowManagerController controller,
  ) {
    final task = controller.allTasks.firstWhereOrNull((t) => t.id == workStep.taskId);
    
    if (task == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task not found'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
