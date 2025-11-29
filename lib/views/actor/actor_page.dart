import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/actor_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_strings.dart';
import '../../config/constants/app_colors.dart';
import '../shared/layouts/jira_layout.dart';
import 'widgets/create_task_dialog.dart';
import '../../views/workflow_manager/widgets/draggable_kanban_board.dart';
import '../../views/workflow_manager/widgets/task_detail/modern_task_detail_dialog.dart';
import '../../../models/work_step.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;
import '../../utils/extensions.dart';

/// Trello-style Actor Page
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
            backgroundColor: const Color(0xFF0079BF), // Trello blue
            body: Column(
              children: [
                // Trello-style minimal header
                _TrelloActorHeader(
                  controller: controller,
                  onCreateTask: () => _showCreateTaskDialog(context, controller),
                ),
                
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

  Widget _buildBody(BuildContext context, ActorController controller) {
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

    // Get all tasks that have work steps assigned to this actor
    final actorTasks = controller.allTasks.where((task) {
      return task.workSteps.any((ws) => ws.assignedToActorId == controller.actorId);
    }).toList();

    if (actorTasks.isEmpty) {
      return Container(
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
                'No tasks assigned to you yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
                  borderRadius: BorderRadius.circular(8),
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

  void _showTaskDetailDialog(
    BuildContext context,
    WorkStep workStep,
    ActorController controller,
  ) {
    final task = controller.allTasks.firstWhereOrNull((t) => t.id == workStep.taskId);
    if (task == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Task not found.'),
          backgroundColor: AppColors.error,
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

/// Trello-style actor header
class _TrelloActorHeader extends StatelessWidget {
  final ActorController controller;
  final VoidCallback onCreateTask;

  const _TrelloActorHeader({
    required this.controller,
    required this.onCreateTask,
  });

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
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Tasks',
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
          
          // Task count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${controller.workSteps.length} tasks',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Create Button
          ElevatedButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF172B4D),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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
