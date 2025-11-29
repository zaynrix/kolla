import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import 'widgets/kanban_board.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;
import '../shared/widgets/empty_state_widget.dart';

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
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppStrings.workflowManager,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.view_kanban),
                  onPressed: () {},
                  tooltip: 'Kanban View',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refresh,
                  tooltip: AppStrings.refresh,
                ),
              ],
            ),
            body: _buildBody(context, controller),
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

    return Column(
      children: [
        // Top bar with search and filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppStrings.search,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: controller.setSearchQuery,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildFilterChip(
                context,
                controller,
                TaskFilter.all,
                AppStrings.allTasks,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                controller,
                TaskFilter.atRisk,
                AppStrings.atRiskTasks,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                controller,
                TaskFilter.overdue,
                AppStrings.overdueTasks,
              ),
            ],
          ),
        ),
        // Kanban board
        Expanded(
          child: controller.filteredTasks.isEmpty
              ? const EmptyStateWidget(
                  message: 'No tasks found',
                  icon: Icons.task_alt,
                )
              : KanbanBoard(
                  tasks: controller.filteredTasks,
                  onCardTap: (workStep) {
                    // Show task details or edit
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WorkflowManagerController controller,
    TaskFilter filter,
    String label,
  ) {
    final isSelected = controller.filter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          controller.setFilter(filter);
        }
      },
    );
  }
}

