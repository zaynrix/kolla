import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../shared/layouts/jira_layout.dart';
import '../workflow_manager/widgets/draggable_kanban_board.dart';
import '../workflow_manager/widgets/task_detail_dialog.dart';
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
              IconButton(
                icon: const Icon(Icons.refresh, size: 22),
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

    return DraggableKanbanBoard(
      tasks: controller.allTasks,
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
    final task = controller.allTasks.firstWhere((t) => t.id == workStep.taskId);
    showDialog(
      context: context,
      builder: (context) => TaskDetailDialog(
        task: task,
        workStep: workStep,
        onUpdate: (updatedTask) {
          controller.updateTask(updatedTask);
        },
      ),
    );
  }
}

