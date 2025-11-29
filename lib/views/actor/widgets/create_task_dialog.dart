import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/subtask.dart';
import '../../../models/enums.dart';
import '../../../models/actor.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_actor_service.dart';

class CreateTaskDialog extends StatefulWidget {
  final String actorId;
  final String actorRole;
  final Function(Task) onCreateTask;

  const CreateTaskDialog({
    super.key,
    required this.actorId,
    required this.actorRole,
    required this.onCreateTask,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _workStepNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _subTaskNameController = TextEditingController();
  
  DateTime? _selectedDeadline;
  final List<_WorkStepData> _workSteps = [];
  final List<_SubTaskData> _subTasks = [];
  String? _selectedAssigneeId;

  @override
  void dispose() {
    _taskNameController.dispose();
    _deadlineController.dispose();
    _workStepNameController.dispose();
    _durationController.dispose();
    _subTaskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actorService = context.read<IActorService>();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_task,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Create New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Task Name
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: 'Task Name *',
                  hintText: 'Enter task name',
                  prefixIcon: const Icon(Icons.task),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Assignee and Deadline Row
              Row(
                children: [
                  // Assignee
                  Expanded(
                    child: FutureBuilder<List<Actor>>(
                      future: actorService.getAllActors(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final actors = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Assign To',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          value: _selectedAssigneeId,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Unassigned', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            ...actors.map((actor) => DropdownMenuItem(
                              value: actor.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
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
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(actor.name),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${actor.role})',
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedAssigneeId = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Deadline
                  Expanded(
                    child: TextFormField(
                      controller: _deadlineController,
                      decoration: InputDecoration(
                        labelText: 'Deadline *',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDeadline = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              _deadlineController.text =
                                  '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        }
                      },
                      validator: (value) {
                        if (_selectedDeadline == null) {
                          return 'Please select a deadline';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Subtasks Section
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subTaskNameController,
                      decoration: InputDecoration(
                        labelText: 'Subtask Name',
                        hintText: 'Add a subtask',
                        prefixIcon: const Icon(Icons.checklist),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onFieldSubmitted: (_) => _addSubTask(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addSubTask,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Subtask'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Subtasks List
              if (_subTasks.isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _subTasks.length,
                    itemBuilder: (context, index) {
                      final subTask = _subTasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: false,
                          onChanged: null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(subTask.name),
                        subtitle: subTask.assignedToActorId != null
                            ? FutureBuilder<Actor>(
                                future: actorService.getActor(subTask.assignedToActorId!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      'Assigned to ${snapshot.data!.name}',
                                      style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () {
                            setState(() {
                              _subTasks.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Work Steps Section
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _workStepNameController,
                      decoration: InputDecoration(
                        labelText: 'Work Step Name',
                        prefixIcon: const Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: 'Hours',
                        prefixIcon: const Icon(Icons.access_time, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addWorkStep,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Work Steps List
              if (_workSteps.isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _workSteps.length,
                    itemBuilder: (context, index) {
                      final step = _workSteps[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 16,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(step.name),
                        subtitle: Text('${step.durationHours}h • ${step.role}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () {
                            setState(() {
                              _workSteps.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              const Spacer(),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _createTask,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Create Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSubTask() {
    if (_subTaskNameController.text.isEmpty) {
      return;
    }

    setState(() {
      _subTasks.add(_SubTaskData(
        name: _subTaskNameController.text,
        assignedToActorId: _selectedAssigneeId,
      ));
      _subTaskNameController.clear();
    });
  }

  void _addWorkStep() {
    if (_workStepNameController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in work step name and duration'),
        ),
      );
      return;
    }

    setState(() {
      _workSteps.add(_WorkStepData(
        name: _workStepNameController.text,
        durationHours: int.parse(_durationController.text),
        role: widget.actorRole,
      ));
      _workStepNameController.clear();
      _durationController.clear();
    });
  }

  void _createTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final workSteps = _workSteps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return WorkStep(
        id: 'ws-${DateTime.now().millisecondsSinceEpoch}-$index',
        taskId: '', // Will be set when task is created
        name: step.name,
        durationHours: step.durationHours,
        role: step.role,
        status: WorkStepStatus.pending,
        assignedToActorId: widget.actorId,
        sequenceOrder: index + 1,
      );
    }).toList();

    final subTasks = _subTasks.asMap().entries.map((entry) {
      final index = entry.key;
      final subTask = entry.value;
      return SubTask(
        id: 'st-${DateTime.now().millisecondsSinceEpoch}-$index',
        taskId: '', // Will be set when task is created
        name: subTask.name,
        status: WorkStepStatus.pending,
        assignedToActorId: subTask.assignedToActorId,
        sequenceOrder: index + 1,
      );
    }).toList();

    final task = Task(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      name: _taskNameController.text,
      deadline: _selectedDeadline!,
      workSteps: workSteps,
      subTasks: subTasks,
      assignedToActorId: _selectedAssigneeId,
    );

    widget.onCreateTask(task);
    Navigator.of(context).pop();
  }
}

class _WorkStepData {
  final String name;
  final int durationHours;
  final String role;

  _WorkStepData({
    required this.name,
    required this.durationHours,
    required this.role,
  });
}

class _SubTaskData {
  final String name;
  final String? assignedToActorId;

  _SubTaskData({
    required this.name,
    this.assignedToActorId,
  });
}
