import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../../models/work_step.dart';
import '../shared/layouts/jira_layout.dart';
import 'widgets/draggable_kanban_board.dart';
import 'widgets/modern_task_detail_dialog.dart';
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
                icon: Icons.view_kanban_rounded,
                onPressed: () {},
                tooltip: 'Kanban View',
              ),
              const SizedBox(width: 8),
              _WebActionButton(
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

    return Column(
      children: [
        // Modern Top Bar with Search and Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _ModernSearchField(
                    hintText: AppStrings.search,
                    onChanged: controller.setSearchQuery,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Filter Chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ModernFilterChip(
                    label: AppStrings.allTasks,
                    isSelected: controller.filter == TaskFilter.all,
                    onSelected: () => controller.setFilter(TaskFilter.all),
                  ),
                  _ModernFilterChip(
                    label: AppStrings.atRiskTasks,
                    isSelected: controller.filter == TaskFilter.atRisk,
                    onSelected: () => controller.setFilter(TaskFilter.atRisk),
                  ),
                  _ModernFilterChip(
                    label: AppStrings.overdueTasks,
                    isSelected: controller.filter == TaskFilter.overdue,
                    onSelected: () => controller.setFilter(TaskFilter.overdue),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Kanban Board
        Expanded(
          child: controller.filteredTasks.isEmpty
              ? Center(
                  child: _EmptyState(
                    message: 'No tasks found',
                    icon: Icons.task_alt_rounded,
                  ),
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
    );
  }

  void _showTaskDetailDialog(
    BuildContext context,
    WorkStep workStep,
    WorkflowManagerController controller,
  ) {
    final task = controller.allTasks.firstWhere((t) => t.id == workStep.taskId);
    showDialog(
      context: context,
      builder: (context) => ModernTaskDetailDialog(
        task: task,
        workStep: workStep,
      ),
    );
  }
}

// Modern Search Field
class _ModernSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const _ModernSearchField({
    required this.hintText,
    this.onChanged,
  });

  @override
  State<_ModernSearchField> createState() => _ModernSearchFieldState();
}

class _ModernSearchFieldState extends State<_ModernSearchField> {
  bool _isFocused = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary
                : AppColors.borderLight,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused
                  ? AppColors.primary
                  : AppColors.textTertiary,
              size: 22,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15,
              ),
        ),
      ),
    );
  }
}

// Modern Filter Chip
class _ModernFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_ModernFilterChip> createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<_ModernFilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : _isHovered
                    ? AppColors.hoverBackground
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.borderLight,
              width: widget.isSelected ? 0 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              if (widget.isSelected) const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern Empty State
class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters or create a new task',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ],
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
