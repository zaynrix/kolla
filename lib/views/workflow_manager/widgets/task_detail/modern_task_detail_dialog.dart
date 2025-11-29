import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/task.dart';
import '../../../../models/work_step.dart';
import '../../../../services/interfaces/i_task_service.dart';
import '../../../../services/interfaces/i_actor_service.dart';
import '../../../../controllers/task_detail_controller.dart';
import 'sections/header_section.dart';
import 'sections/description_section.dart';
import 'sections/assignee_section.dart';
import 'sections/subtasks_section.dart';
import 'sections/work_steps_section.dart';

/// Modern task detail dialog
/// Single Responsibility: Coordinate task detail display and editing
/// Uses composition to delegate to specialized section widgets
class ModernTaskDetailDialog extends StatelessWidget {
  final Task task;
  final WorkStep? workStep;

  const ModernTaskDetailDialog({
    super.key,
    required this.task,
    this.workStep,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskDetailController(
        taskService: context.read<ITaskService>(),
        actorService: context.read<IActorService>(),
        initialTask: task,
      ),
      child: Consumer<TaskDetailController>(
        builder: (context, controller, _) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  HeaderSection(
                    task: controller.task,
                    isEditing: controller.isEditing,
                    onToggleEdit: () => controller.toggleEdit(),
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),

                  // Main Content - Scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description Section
                          DescriptionSection(
                            description: controller.task.description,
                            isEditing: controller.isEditing,
                            onUpdate: (desc) =>
                                controller.updateDescription(desc),
                          ),
                          const SizedBox(height: 24),

                          // Assignee Section
                          AssigneeSection(
                            assignedToActorId:
                                controller.task.assignedToActorId,
                            availableActors: controller.availableActors,
                            isEditing: controller.isEditing,
                            onUpdate: (actorId) =>
                                controller.updateAssignee(actorId),
                          ),
                          const SizedBox(height: 24),

                          // Subtasks Section
                          SubtasksSection(
                            subTasks: controller.task.subTasks,
                            availableActors: controller.availableActors,
                            isEditing: controller.isEditing,
                            onAdd: (name, actorId) =>
                                controller.addSubTask(name, actorId),
                            onComplete: (subTaskId) =>
                                controller.completeSubTask(subTaskId),
                            onDelete: (subTaskId) =>
                                controller.deleteSubTask(subTaskId),
                          ),
                          const SizedBox(height: 24),

                          // Work Steps Section
                          WorkStepsSection(
                            workSteps: controller.task.workSteps,
                            onStatusChange: (workStepId, newStatus) async {
                              final taskService =
                                  context.read<ITaskService>();
                              await taskService.updateWorkStepStatus(
                                  workStepId, newStatus);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                      if (controller.isEditing)
                        ElevatedButton(
                          onPressed: () {
                            controller.saveTask();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

