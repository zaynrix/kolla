import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../shared/layouts/jira_layout.dart';
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
          return JiraLayout(
            title: AppStrings.workflowManager,
            actions: [
              _WebActionButton(
                icon: Icons.view_kanban,
                onPressed: () {},
                tooltip: 'Kanban View',
              ),
              const SizedBox(width: 8),
              _WebActionButton(
                icon: Icons.refresh,
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

    return Column(
      children: [
        // Top bar with search and filters - Web optimized
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppStrings.search,
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: controller.setSearchQuery,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildFilterChip(
                context,
                controller,
                TaskFilter.all,
                AppStrings.allTasks,
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                context,
                controller,
                TaskFilter.atRisk,
                AppStrings.atRiskTasks,
              ),
              const SizedBox(width: 12),
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
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.hoverBackground,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          controller.setFilter(filter);
        }
      },
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
                border: _isHovered
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      )
                    : null,
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

