import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/subtask.dart';
import '../../../models/enums.dart';
import '../../../models/actor.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_task_service.dart';
import '../../../services/interfaces/i_actor_service.dart';
import '../../../controllers/task_detail_controller.dart';

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
                  _HeaderSection(
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
                          _DescriptionSection(
                            description: controller.task.description,
                            isEditing: controller.isEditing,
                            onUpdate: (desc) => controller.updateDescription(desc),
                          ),
                          const SizedBox(height: 24),
                          
                          // Assignee Section
                          _AssigneeSection(
                            assignedToActorId: controller.task.assignedToActorId,
                            availableActors: controller.availableActors,
                            isEditing: controller.isEditing,
                            onUpdate: (actorId) => controller.updateAssignee(actorId),
                          ),
                          const SizedBox(height: 24),
                          
                          // Subtasks Section
                          _SubtasksSection(
                            subTasks: controller.task.subTasks,
                            availableActors: controller.availableActors,
                            isEditing: controller.isEditing,
                            onAdd: (name, actorId) => controller.addSubTask(name, actorId),
                            onComplete: (subTaskId) => controller.completeSubTask(subTaskId),
                            onDelete: (subTaskId) => controller.deleteSubTask(subTaskId),
                          ),
                          const SizedBox(height: 24),
                          
                          // Work Steps Section
                          _WorkStepsSection(
                            workSteps: controller.task.workSteps,
                            onStatusChange: (workStepId, newStatus) async {
                              final taskService = context.read<ITaskService>();
                              await taskService.updateWorkStepStatus(workStepId, newStatus);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action Buttons
                  const SizedBox(height: 24),
                  _ActionButtons(
                    isEditing: controller.isEditing,
                    isLoading: controller.isLoading,
                    onSave: () => controller.saveTask(),
                    onCancel: () => controller.toggleEdit(),
                    onClose: () => Navigator.of(context).pop(),
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

// Header Section
class _HeaderSection extends StatelessWidget {
  final Task task;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onClose;

  const _HeaderSection({
    required this.task,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextField(
                  controller: TextEditingController(text: task.name),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    // Update handled by controller
                  },
                )
              : Text(
                  task.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(isEditing ? Icons.close : Icons.edit),
          onPressed: onToggleEdit,
          tooltip: isEditing ? 'Cancel' : 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }
}

// Description Section - Trello style
class _DescriptionSection extends StatelessWidget {
  final String? description;
  final bool isEditing;
  final Function(String?) onUpdate;

  const _DescriptionSection({
    required this.description,
    required this.isEditing,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        isEditing
            ? TextField(
                controller: TextEditingController(text: description ?? ''),
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Add a more detailed description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                ),
                onChanged: (value) => onUpdate(value.isEmpty ? null : value),
              )
            : GestureDetector(
                onTap: () => onUpdate(description),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: description == null
                        ? AppColors.backgroundLight
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: description == null
                          ? AppColors.borderLight
                          : Colors.transparent,
                    ),
                  ),
                  child: description == null
                      ? Text(
                          'Add a more detailed description...',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ),
      ],
    );
  }
}

// Assignee Section
class _AssigneeSection extends StatelessWidget {
  final String? assignedToActorId;
  final List<Actor> availableActors;
  final bool isEditing;
  final Function(String?) onUpdate;

  const _AssigneeSection({
    required this.assignedToActorId,
    required this.availableActors,
    required this.isEditing,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final assignedActor = availableActors.firstWhere(
      (a) => a.id == assignedToActorId,
      orElse: () => availableActors.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Assignee',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        isEditing
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButton<String>(
                  value: assignedToActorId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...availableActors.map((actor) {
                      return DropdownMenuItem<String>(
                        value: actor.id,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.primaryGradient,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  actor.name[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(actor.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) => onUpdate(value),
                ),
              )
            : GestureDetector(
                onTap: () => onUpdate(assignedToActorId),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            assignedActor.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        assignedActor.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

// Subtasks Section - Modern design
class _SubtasksSection extends StatelessWidget {
  final List<SubTask> subTasks;
  final List<Actor> availableActors;
  final bool isEditing;
  final Function(String, String?) onAdd;
  final Function(String) onComplete;
  final Function(String) onDelete;

  const _SubtasksSection({
    required this.subTasks,
    required this.availableActors,
    required this.isEditing,
    required this.onAdd,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checklist, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Subtasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${subTasks.where((st) => st.status == WorkStepStatus.completed).length}/${subTasks.length}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...subTasks.map((subTask) => _SubTaskItem(
              subTask: subTask,
              availableActors: availableActors,
              isEditing: isEditing,
              onComplete: () => onComplete(subTask.id),
              onDelete: () => onDelete(subTask.id),
            )),
        if (isEditing) ...[
          const SizedBox(height: 8),
          _AddSubTaskButton(
            availableActors: availableActors,
            onAdd: onAdd,
          ),
        ],
      ],
    );
  }
}

// SubTask Item
class _SubTaskItem extends StatelessWidget {
  final SubTask subTask;
  final List<Actor> availableActors;
  final bool isEditing;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _SubTaskItem({
    required this.subTask,
    required this.availableActors,
    required this.isEditing,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = subTask.status == WorkStepStatus.completed;
    final assignedActor = availableActors.firstWhere(
      (a) => a.id == subTask.assignedToActorId,
      orElse: () => availableActors.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.backgroundLight
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.borderLight
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: isCompleted ? null : (_) => onComplete(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Text(
              subTask.name,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
                fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
          if (subTask.assignedToActorId != null)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  assignedActor.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              color: AppColors.overdue,
            ),
        ],
      ),
    );
  }
}

// Add SubTask Button
class _AddSubTaskButton extends StatefulWidget {
  final List<Actor> availableActors;
  final Function(String, String?) onAdd;

  const _AddSubTaskButton({
    required this.availableActors,
    required this.onAdd,
  });

  @override
  State<_AddSubTaskButton> createState() => _AddSubTaskButtonState();
}

class _AddSubTaskButtonState extends State<_AddSubTaskButton> {
  final _controller = TextEditingController();
  String? _selectedActorId;
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return TextButton.icon(
        onPressed: () => setState(() => _isExpanded = true),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add subtask'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Subtask name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedActorId,
                  hint: const Text('Assign to (optional)'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...widget.availableActors.map((actor) {
                      return DropdownMenuItem<String>(
                        value: actor.id,
                        child: Text(actor.name),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _selectedActorId = value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onAdd(_controller.text, _selectedActorId);
                    _controller.clear();
                    _selectedActorId = null;
                    setState(() => _isExpanded = false);
                  }
                },
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  _selectedActorId = null;
                  setState(() => _isExpanded = false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Work Steps Section
class _WorkStepsSection extends StatelessWidget {
  final List<WorkStep> workSteps;
  final Function(String, WorkStepStatus) onStatusChange;

  const _WorkStepsSection({
    required this.workSteps,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Work Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...workSteps.map((step) => _WorkStepItem(
              workStep: step,
              onStatusChange: (newStatus) => onStatusChange(step.id, newStatus),
            )),
      ],
    );
  }
}

// WorkStep Item
class _WorkStepItem extends StatelessWidget {
  final WorkStep workStep;
  final Function(WorkStepStatus) onStatusChange;

  const _WorkStepItem({
    required this.workStep,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workStep.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workStep.role,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${workStep.durationHours}h',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DropdownButton<WorkStepStatus>(
            value: workStep.status,
            items: WorkStepStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusLabel(status)),
              );
            }).toList(),
            onChanged: (newStatus) {
              if (newStatus != null && newStatus != workStep.status) {
                onStatusChange(newStatus);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(WorkStepStatus status) {
    switch (status) {
      case WorkStepStatus.pending:
        return 'To Do';
      case WorkStepStatus.inProgress:
        return 'In Progress';
      case WorkStepStatus.completed:
        return 'Done';
    }
  }
}

// Action Buttons
class _ActionButtons extends StatelessWidget {
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onClose;

  const _ActionButtons({
    required this.isEditing,
    required this.isLoading,
    required this.onSave,
    required this.onCancel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isEditing) ...[
          TextButton(
            onPressed: isLoading ? null : onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onSave,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, size: 18),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ] else
          TextButton(
            onPressed: onClose,
            child: const Text('Close'),
          ),
      ],
    );
  }
}

