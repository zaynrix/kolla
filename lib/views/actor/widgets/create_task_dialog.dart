import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';

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
  
  DateTime? _selectedDeadline;
  final List<_WorkStepData> _workSteps = [];

  @override
  void dispose() {
    _taskNameController.dispose();
    _deadlineController.dispose();
    _workStepNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                      'New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  prefixIcon: const Icon(Icons.task),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  labelText: 'Deadline',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                  if (date != null) {
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _workStepNameController,
                      decoration: InputDecoration(
                        labelText: 'Work Step Name',
                        prefixIcon: const Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addWorkStep,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_workSteps.isNotEmpty) ...[
                Text(
                  'Work Steps (${_workSteps.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _workSteps.length,
                    itemBuilder: (context, index) {
                      final step = _workSteps[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(step.name),
                        subtitle: Text('${step.durationHours}h • ${step.role}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
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
                    icon: const Icon(Icons.check),
                    label: const Text('Create Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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

    if (_workSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one work step'),
        ),
      );
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

    final task = Task(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      name: _taskNameController.text,
      deadline: _selectedDeadline!,
      workSteps: workSteps,
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

