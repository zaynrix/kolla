import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/actor.dart';
import '../models/enums.dart';
import '../services/interfaces/i_task_service.dart';
import '../services/interfaces/i_actor_service.dart';

class TaskDetailController extends ChangeNotifier {
  final ITaskService _taskService;
  final IActorService _actorService;
  final Task _initialTask;

  Task _task;
  List<Actor> _availableActors = [];
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;

  TaskDetailController({
    required ITaskService taskService,
    required IActorService actorService,
    required Task initialTask,
  })  : _taskService = taskService,
        _actorService = actorService,
        _initialTask = initialTask,
        _task = initialTask {
    _init();
  }

  Task get task => _task;
  List<Actor> get availableActors => _availableActors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEditing => _isEditing;

  void _init() {
    _loadActors();
  }

  Future<void> _loadActors() async {
    try {
      _availableActors = await _actorService.getAllActors();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleEdit() {
    _isEditing = !_isEditing;
    if (!_isEditing) {
      // Reset to initial task if cancelled
      _task = _initialTask;
    }
    notifyListeners();
  }

  void updateName(String name) {
    _task = _task.copyWith(name: name);
    notifyListeners();
  }

  void updateDescription(String? description) {
    _task = _task.copyWith(description: description);
    notifyListeners();
  }

  void updateAssignee(String? actorId) {
    _task = _task.copyWith(assignedToActorId: actorId);
    notifyListeners();
  }

  void addSubTask(String name, String? assignedToActorId) {
    final newSubTask = SubTask(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      taskId: _task.id,
      name: name,
      status: WorkStepStatus.pending,
      assignedToActorId: assignedToActorId,
      sequenceOrder: _task.subTasks.length + 1,
    );
    final updatedSubTasks = List<SubTask>.from(_task.subTasks)..add(newSubTask);
    _task = _task.copyWith(subTasks: updatedSubTasks);
    notifyListeners();
  }

  Future<void> completeSubTask(String subTaskId) async {
    try {
      // Update local state immediately for UI responsiveness
      final subTaskIndex = _task.subTasks.indexWhere((st) => st.id == subTaskId);
      if (subTaskIndex != -1) {
        final currentSubTask = _task.subTasks[subTaskIndex];
        final newStatus = currentSubTask.status == WorkStepStatus.completed
            ? WorkStepStatus.pending
            : WorkStepStatus.completed;
        final updatedSubTask = currentSubTask.copyWith(status: newStatus);
        final updatedSubTasks = List<SubTask>.from(_task.subTasks);
        updatedSubTasks[subTaskIndex] = updatedSubTask;
        _task = _task.copyWith(subTasks: updatedSubTasks);
        notifyListeners(); // Update UI immediately
      }
      
      // Then persist to service
      await _taskService.completeSubTask(subTaskId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveTask() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _taskService.updateTask(_task);
      _isEditing = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSubTask(String subTaskId) async {
    final updatedSubTasks = _task.subTasks.where((st) => st.id != subTaskId).toList();
    _task = _task.copyWith(subTasks: updatedSubTasks);
    notifyListeners();
    
    // Also update via service if needed
    try {
      await _taskService.updateTask(_task);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

