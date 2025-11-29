import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/work_step.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/enums.dart';
import '../services/interfaces/i_task_service.dart';
import '../services/interfaces/i_notification_service.dart';
import '../utils/extensions.dart';

enum ViewMode { list, chart }

class ActorController extends ChangeNotifier {
  final ITaskService _taskService;
  final INotificationService _notificationService;
  final String actorId;

  List<WorkStep> _workSteps = [];
  List<Task> _allTasks = [];
  List<SubTask> _assignedSubTasks = [];
  bool _isLoading = false;
  String? _error;
  ViewMode _viewMode = ViewMode.list;

  StreamSubscription? _workStepsSubscription;

  ActorController({
    required ITaskService taskService,
    required INotificationService notificationService,
    required this.actorId,
  })  : _taskService = taskService,
        _notificationService = notificationService {
    _init();
  }

  // Getters
  List<WorkStep> get workSteps => _workSteps;
  List<Task> get allTasks => _allTasks;
  List<SubTask> get assignedSubTasks => _assignedSubTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ViewMode get viewMode => _viewMode;

  // Get work steps grouped by priority
  List<WorkStep> get immediateWorkSteps =>
      _getWorkStepsByPriority(Priority.immediate);
  List<WorkStep> get mediumWorkSteps =>
      _getWorkStepsByPriority(Priority.medium);
  List<WorkStep> get longTermWorkSteps =>
      _getWorkStepsByPriority(Priority.longTerm);

  List<WorkStep> _getWorkStepsByPriority(Priority priority) {
    return _workSteps.where((ws) {
      // Include all work steps (completed and pending) like Jira/Trello
      final task = _allTasks.firstWhere((t) => t.id == ws.taskId);
      final remainingSteps = task.workSteps
          .where((tws) =>
              tws.sequenceOrder > ws.sequenceOrder &&
              tws.status != WorkStepStatus.completed)
          .length;
      return ws.getEffectivePriority(task.deadline, remainingSteps) == priority;
    }).toList();
  }

  // Get completed work steps (for display)
  List<WorkStep> get completedWorkSteps {
    return _workSteps
        .where((ws) => ws.status == WorkStepStatus.completed)
        .toList();
  }

  // Get pending work steps
  List<WorkStep> get pendingWorkSteps {
    return _workSteps
        .where((ws) => ws.status == WorkStepStatus.pending)
        .toList();
  }

  void _init() {
    _loadWorkSteps();
    _subscribeToWorkSteps();
  }

  Future<void> _loadWorkSteps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTasks = await _taskService.getAllTasks();
      _workSteps = await _taskService.getActorWorkSteps(actorId);
      
      // Get all subtasks assigned to this actor
      _assignedSubTasks = _getAssignedSubTasks();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  List<SubTask> _getAssignedSubTasks() {
    final subtasks = <SubTask>[];
    for (var task in _allTasks) {
      for (var subtask in task.subTasks) {
        if (subtask.assignedToActorId == actorId) {
          subtasks.add(subtask);
        }
      }
    }
    return subtasks;
  }

  void _subscribeToWorkSteps() {
    _workStepsSubscription = _taskService.watchActorWorkSteps(actorId).listen(
      (workSteps) {
        _workSteps = workSteps;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    // Also watch all tasks for deadline info and subtasks
    _taskService.watchAllTasks().listen((tasks) {
      _allTasks = tasks;
      _assignedSubTasks = _getAssignedSubTasks();
      notifyListeners();
    });
  }

  Future<void> completeWorkStep(String workStepId) async {
    try {
      await _taskService.completeWorkStep(workStepId);

      // Send notification about work step completion
      final workStep = _workSteps.firstWhereOrNull((ws) => ws.id == workStepId);
      if (workStep != null) {
        final task = _allTasks.firstWhereOrNull((t) => t.id == workStep.taskId);
        if (task != null) {
          _notificationService.notifyWorkStepCompleted(workStep, task);
        }
      }

      // Update happens via stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateWorkStepStatus(
      String workStepId, WorkStepStatus status) async {
    try {
      await _taskService.updateWorkStepStatus(workStepId, status);

      // Send notification about status change
      final workStep = _workSteps.firstWhereOrNull((ws) => ws.id == workStepId);
      if (workStep != null) {
        final task = _allTasks.firstWhereOrNull((t) => t.id == workStep.taskId);
        if (task != null) {
          _notificationService.notifyWorkStepCompleted(workStep, task);
        }
      }

      // Update happens via stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.list ? ViewMode.chart : ViewMode.list;
    notifyListeners();
  }

  void refresh() {
    _loadWorkSteps();
  }

  Task getTaskForWorkStep(WorkStep workStep) {
    return _allTasks.firstWhere((t) => t.id == workStep.taskId);
  }

  Future<void> createTask(Task task) async {
    try {
      await _taskService.createTask(
        task.name,
        task.deadline,
        task.workSteps,
        subTasks: task.subTasks,
        assignedToActorId: task.assignedToActorId,
      );
      // Update happens via stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _workStepsSubscription?.cancel();
    super.dispose();
  }
}
