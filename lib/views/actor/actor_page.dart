import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/actor_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import 'widgets/task_list_view.dart';
import 'widgets/task_chart_view.dart';
import 'widgets/create_task_dialog.dart';
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
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.myTasks,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                      Text(
                        '${controller.workSteps.length} active tasks',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: controller.viewMode == ViewMode.list
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.hoverBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.view_list,
                      size: 22,
                      color: controller.viewMode == ViewMode.list
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    onPressed: controller.viewMode == ViewMode.list
                        ? null
                        : controller.toggleViewMode,
                    tooltip: 'List View',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: controller.viewMode == ViewMode.chart
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.hoverBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      size: 22,
                      color: controller.viewMode == ViewMode.chart
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    onPressed: controller.viewMode == ViewMode.chart
                        ? null
                        : controller.toggleViewMode,
                    tooltip: 'Chart View',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.hoverBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 22),
                    onPressed: controller.refresh,
                    tooltip: AppStrings.refresh,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 22, color: Colors.white),
                    onPressed: () => _showCreateTaskDialog(context, controller),
                    tooltip: 'Create New Task',
                  ),
                ),
              ],
            ),
            body: _buildBody(controller),
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

    return controller.viewMode == ViewMode.list
        ? TaskListView(controller: controller)
        : TaskChartView(controller: controller);
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

