import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/task.dart';
import '../models/actor.dart';
import '../models/work_step.dart';
import '../models/enums.dart';
import '../services/interfaces/i_task_service.dart';
import '../services/interfaces/i_actor_service.dart';

enum TaskFilter { all, atRisk, overdue }

class WorkflowManagerController extends ChangeNotifier {
  final ITaskService _taskService;
  final IActorService _actorService;

  List<Task> _allTasks = [];
  List<Actor> _allActors = [];
  bool _isLoading = false;
  String? _error;
  TaskFilter _filter = TaskFilter.all;
  String _searchQuery = '';

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _actorsSubscription;

  WorkflowManagerController({
    required ITaskService taskService,
    required IActorService actorService,
  })  : _taskService = taskService,
        _actorService = actorService {
    _init();
  }

  // Getters
  List<Task> get allTasks => _allTasks;
  List<Actor> get allActors => _allActors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<Task> get filteredTasks {
    var tasks = _allTasks;

    // Apply filter
    switch (_filter) {
      case TaskFilter.atRisk:
        tasks = tasks.where((t) => t.status == TaskStatus.atRisk).toList();
        break;
      case TaskFilter.overdue:
        tasks = tasks.where((t) => t.status == TaskStatus.overdue).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((t) =>
              t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return tasks;
  }

  void _init() {
    _loadData();
    _subscribeToData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTasks = await _taskService.getAllTasks();
      _allActors = await _actorService.getAllActors();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToData() {
    _tasksSubscription = _taskService.watchAllTasks().listen(
      (tasks) {
        _allTasks = tasks;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    _actorsSubscription = _actorService.watchAllActors().listen(
      (actors) {
        _allActors = actors;
        notifyListeners();
      },
    );
  }

  void setFilter(TaskFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateWorkStepPriority(String workStepId, Priority priority) async {
    try {
      await _taskService.updateWorkStepPriority(workStepId, priority);
      // Update happens via stream
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  int getActorWorkloadCount(String actorId) {
    int count = 0;
    for (var task in _allTasks) {
      count += task.workSteps
          .where((ws) =>
              ws.assignedToActorId == actorId &&
              ws.status == WorkStepStatus.pending)
          .length;
    }
    return count;
  }

  List<WorkStep> getActorWorkSteps(String actorId) {
    final workSteps = <WorkStep>[];
    for (var task in _allTasks) {
      workSteps.addAll(
        task.workSteps.where((ws) =>
            ws.assignedToActorId == actorId &&
            ws.status == WorkStepStatus.pending),
      );
    }
    return workSteps;
  }

  void refresh() {
    _loadData();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _actorsSubscription?.cancel();
    super.dispose();
  }
}

