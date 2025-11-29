import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_colors.dart';
import '../../models/work_step.dart';
import '../../utils/extensions.dart';
import 'widgets/draggable_kanban_board.dart';
import 'widgets/task_detail/modern_task_detail_dialog.dart';
import '../shared/widgets/error_widget.dart' as custom;
import 'widgets/trello_search_bar.dart';

/// Trello-style Workflow Manager Page
class WorkflowManagerPage extends StatelessWidget {
  const WorkflowManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkflowManagerController(
        taskService: context.read<ITaskService>(),
        actorService: context.read<IActorService>(),
      ),
      child: Consumer<WorkflowManagerController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF0079BF), // Trello blue
            body: Column(
              children: [
                // Trello-style minimal header
                _TrelloHeader(controller: controller),
                
                // Kanban Board
                Expanded(
                  child: _buildBody(context, controller),
                ),
              ],
            ),
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
      return Container(
        color: const Color(0xFF0079BF),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (controller.error != null) {
      return Container(
        color: const Color(0xFF0079BF),
        child: Center(
          child: custom.ErrorWidget(
            error: controller.error!,
            onRetry: controller.refresh,
          ),
        ),
      );
    }

    return controller.filteredTasks.isEmpty
        ? Container(
            color: const Color(0xFF0079BF),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        : DraggableKanbanBoard(
            tasks: controller.filteredTasks,
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
    WorkflowManagerController controller,
  ) {
    final task = controller.allTasks.firstWhereOrNull((t) => t.id == workStep.taskId) ??
        controller.filteredTasks.firstWhereOrNull((t) => t.id == workStep.taskId);
    
    if (task == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task not found'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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

/// Trello-style minimal header
class _TrelloHeader extends StatelessWidget {
  final WorkflowManagerController controller;

  const _TrelloHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF026AA7), // Darker Trello blue
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo/Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Workflow Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Search Bar
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TrelloSearchBar(
                onChanged: controller.setSearchQuery,
                initialValue: controller.searchQuery,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Filter Buttons
          _TrelloFilterButton(
            label: 'All',
            isSelected: controller.filter == TaskFilter.all,
            onTap: () => controller.setFilter(TaskFilter.all),
          ),
          const SizedBox(width: 8),
          _TrelloFilterButton(
            label: 'At Risk',
            isSelected: controller.filter == TaskFilter.atRisk,
            onTap: () => controller.setFilter(TaskFilter.atRisk),
          ),
          const SizedBox(width: 8),
          _TrelloFilterButton(
            label: 'Overdue',
            isSelected: controller.filter == TaskFilter.overdue,
            onTap: () => controller.setFilter(TaskFilter.overdue),
          ),
          
          const SizedBox(width: 16),
          
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: controller.refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

/// Trello-style filter button
class _TrelloFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TrelloFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
