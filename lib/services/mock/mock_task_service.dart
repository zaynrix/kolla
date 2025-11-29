import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../interfaces/i_task_service.dart';
import '../../models/task.dart';
import '../../models/work_step.dart';
import '../../models/subtask.dart';
import '../../models/enums.dart';
import 'data/mock_task_data.dart';

/// Mock task service implementation
/// Single Responsibility: Provide mock task data and operations
/// Dependency Inversion: Depends on ITaskService interface
class MockTaskService implements ITaskService {
  final _tasksSubject = BehaviorSubject<List<Task>>.seeded([]);
  List<Task> _tasks = [];
  Timer? _autoCompleteTimer;

  MockTaskService() {
    _initializeMockData();
    _startAutoCompletion();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    // Use Factory Pattern for data creation
    // Single Responsibility: Data generation separated from service logic
    _tasks = MockTaskDataFactory.createMockTasks(now);
    _tasksSubject.add(_tasks);
  }

  void _startAutoCompletion() {
    // Simulate work step completion every 15-20 seconds
    _autoCompleteTimer = Timer.periodic(
      const Duration(seconds: 17),
      (_) => _completeRandomWorkStep(),
    );
  }

  void _completeRandomWorkStep() {
    // Find all pending work steps
    final allPendingSteps = <WorkStep>[];
    for (var task in _tasks) {
      allPendingSteps.addAll(
        task.workSteps.where((ws) => ws.status == WorkStepStatus.pending),
      );
    }
    if (allPendingSteps.isEmpty) return;

    // Pick random one
    allPendingSteps.shuffle();
    final stepToComplete = allPendingSteps.first;

    // Complete it
    completeWorkStep(stepToComplete.id);
    // Note: In production, use a logging framework instead of print
    if (kDebugMode) {
      debugPrint('Auto-completed: ${stepToComplete.name} from task ${stepToComplete.taskId}');
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _tasks;
  }

  @override
  Stream<List<Task>> watchAllTasks() {
    return _tasksSubject.stream;
  }

  @override
  Future<List<WorkStep>> getActorWorkSteps(String actorId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final workSteps = <WorkStep>[];
    for (var task in _tasks) {
      // Include ALL work steps assigned to actor (including completed ones)
      // Like Jira/Trello - completed items stay visible
      final actorSteps = task.workSteps.where((ws) =>
          ws.assignedToActorId == actorId);
      workSteps.addAll(actorSteps);
    }

    // Sort by priority
    workSteps.sort((a, b) {
      final taskA = _tasks.firstWhere((t) => t.id == a.taskId);
      final taskB = _tasks.firstWhere((t) => t.id == b.taskId);

      final remainingA = taskA.workSteps
          .where((ws) =>
              ws.sequenceOrder > a.sequenceOrder &&
              ws.status != WorkStepStatus.completed)
          .length;
      final remainingB = taskB.workSteps
          .where((ws) =>
              ws.sequenceOrder > b.sequenceOrder &&
              ws.status != WorkStepStatus.completed)
          .length;

      final priorityA = a.getEffectivePriority(taskA.deadline, remainingA);
      final priorityB = b.getEffectivePriority(taskB.deadline, remainingB);

      return priorityA.index.compareTo(priorityB.index);
    });

    return workSteps;
  }

  @override
  Stream<List<WorkStep>> watchActorWorkSteps(String actorId) {
    return _tasksSubject.stream.map((tasks) {
      final workSteps = <WorkStep>[];
      for (var task in tasks) {
        final actorSteps = task.workSteps.where((ws) =>
            ws.assignedToActorId == actorId);
        workSteps.addAll(actorSteps);
      }

      // Sort by priority
      workSteps.sort((a, b) {
        final taskA = tasks.firstWhere((t) => t.id == a.taskId);
        final taskB = tasks.firstWhere((t) => t.id == b.taskId);

        final remainingA = taskA.workSteps
            .where((ws) =>
                ws.sequenceOrder > a.sequenceOrder &&
                ws.status != WorkStepStatus.completed)
            .length;
        final remainingB = taskB.workSteps
            .where((ws) =>
                ws.sequenceOrder > b.sequenceOrder &&
                ws.status != WorkStepStatus.completed)
            .length;

        final priorityA = a.getEffectivePriority(taskA.deadline, remainingA);
        final priorityB = b.getEffectivePriority(taskB.deadline, remainingB);

        return priorityA.index.compareTo(priorityB.index);
      });

      return workSteps;
    });
  }

  @override
  Future<void> completeWorkStep(String workStepId) async {
    await updateWorkStepStatus(workStepId, WorkStepStatus.completed);
  }

  @override
  Future<void> updateWorkStepStatus(String workStepId, WorkStepStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Find task and work step
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final stepIndex = task.workSteps.indexWhere((ws) => ws.id == workStepId);

      if (stepIndex != -1) {
        final step = task.workSteps[stepIndex];

        // Update status
        final updatedStep = step.copyWith(status: status);

        // Create new work steps list
        final updatedSteps = List<WorkStep>.from(task.workSteps);
        updatedSteps[stepIndex] = updatedStep;

        // Update task
        _tasks[i] = task.copyWith(workSteps: updatedSteps);
        break;
      }
    }

    // Emit update
    _tasksSubject.add(_tasks);
  }

  @override
  Future<void> updateWorkStepPriority(String workStepId, Priority priority) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final stepIndex = task.workSteps.indexWhere((ws) => ws.id == workStepId);

      if (stepIndex != -1) {
        final step = task.workSteps[stepIndex];
        final updatedStep = step.copyWith(manualPriority: priority);

        final updatedSteps = List<WorkStep>.from(task.workSteps);
        updatedSteps[stepIndex] = updatedStep;

        _tasks[i] = task.copyWith(workSteps: updatedSteps);
        break;
      }
    }

    _tasksSubject.add(_tasks);
  }

  @override
  Future<Task> getTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tasks.firstWhere((t) => t.id == taskId);
  }

  @override
  Future<Task> createTask(String name, DateTime deadline, List<WorkStep> workSteps, {List<SubTask>? subTasks, String? assignedToActorId, String? description}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newTaskId = 'task-${_tasks.length + 1}';
    final newTask = Task(
      id: newTaskId,
      name: name,
      description: description,
      deadline: deadline,
      workSteps: workSteps.map((ws) => ws.copyWith(taskId: newTaskId)).toList(),
      subTasks: subTasks?.map((st) => st.copyWith(taskId: newTaskId)).toList() ?? [],
      assignedToActorId: assignedToActorId,
    );

    _tasks.add(newTask);
    _tasksSubject.add(_tasks);
    return newTask;
  }

  @override
  Future<void> addSubTask(String taskId, SubTask subTask) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubTasks = List<SubTask>.from(task.subTasks)..add(subTask);
      _tasks[taskIndex] = task.copyWith(subTasks: updatedSubTasks);
      _tasksSubject.add(_tasks);
    }
  }

  @override
  Future<void> completeSubTask(String subTaskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final subTaskIndex = task.subTasks.indexWhere((st) => st.id == subTaskId);
      if (subTaskIndex != -1) {
        final subTask = task.subTasks[subTaskIndex];
        // Toggle status: completed <-> pending
        final newStatus = subTask.status == WorkStepStatus.completed
            ? WorkStepStatus.pending
            : WorkStepStatus.completed;
        final updatedSubTask = subTask.copyWith(status: newStatus);
        final updatedSubTasks = List<SubTask>.from(task.subTasks);
        updatedSubTasks[subTaskIndex] = updatedSubTask;
        _tasks[i] = task.copyWith(subTasks: updatedSubTasks);
        break;
      }
    }
    _tasksSubject.add(_tasks);
  }

  @override
  Future<void> assignTask(String taskId, String actorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == taskId) {
        _tasks[i] = _tasks[i].copyWith(assignedToActorId: actorId);
        break;
      }
    }
    
    _tasksSubject.add(_tasks);
  }

  @override
  Future<Task> updateTask(Task updatedTask) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == updatedTask.id) {
        _tasks[i] = updatedTask;
        break;
      }
    }
    
    _tasksSubject.add(_tasks);
    return updatedTask;
  }

  @override
  void dispose() {
    _autoCompleteTimer?.cancel();
    _tasksSubject.close();
  }
}
