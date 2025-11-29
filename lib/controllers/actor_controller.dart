import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/work_step.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../services/interfaces/i_task_service.dart';

enum ViewMode { list, chart }

class ActorController extends ChangeNotifier {
  final ITaskService _taskService;
  final String actorId;

  List<WorkStep> _workSteps = [];
  List<Task> _allTasks = [];
  bool _isLoading = false;
  String? _error;
  ViewMode _viewMode = ViewMode.list;

  StreamSubscription? _workStepsSubscription;

  ActorController({
    required ITaskService taskService,
    required this.actorId,
  }) : _taskService = taskService {
    _init();
  }

  // Getters
  List<WorkStep> get workSteps => _workSteps;
  List<Task> get allTasks => _allTasks;
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
      final task = _allTasks.firstWhere((t) => t.id == ws.taskId);
      final remainingSteps = task.workSteps
          .where((tws) =>
              tws.sequenceOrder > ws.sequenceOrder &&
              tws.status != WorkStepStatus.completed)
          .length;
      return ws.getEffectivePriority(task.deadline, remainingSteps) == priority;
    }).toList();
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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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

    // Also watch all tasks for deadline info
    _taskService.watchAllTasks().listen((tasks) {
      _allTasks = tasks;
      notifyListeners();
    });
  }

  Future<void> completeWorkStep(String workStepId) async {
    try {
      await _taskService.completeWorkStep(workStepId);
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

  @override
  void dispose() {
    _workStepsSubscription?.cancel();
    super.dispose();
  }
}

