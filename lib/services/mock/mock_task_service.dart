import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../interfaces/i_task_service.dart';
import '../../models/task.dart';
import '../../models/work_step.dart';
import '../../models/subtask.dart';
import '../../models/enums.dart';

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

    _tasks = [
      // Task 1: Urgent - Website Redesign
      Task(
        id: 'task-1',
        name: 'Website Redesign',
        deadline: now.add(const Duration(hours: 16)),
        workSteps: [
          WorkStep(
            id: 'ws-1',
            taskId: 'task-1',
            name: 'Create design mockup',
            durationHours: 4,
            role: 'Designer',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-2',
            taskId: 'task-1',
            name: 'Frontend implementation',
            durationHours: 8,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-3',
            taskId: 'task-1',
            name: 'QA Testing',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 2: Medium - Database Migration
      Task(
        id: 'task-2',
        name: 'Database Migration',
        deadline: now.add(const Duration(days: 3)),
        workSteps: [
          WorkStep(
            id: 'ws-4',
            taskId: 'task-2',
            name: 'Backup current database',
            durationHours: 2,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-5',
            taskId: 'task-2',
            name: 'Schema migration script',
            durationHours: 6,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-6',
            taskId: 'task-2',
            name: 'Data validation',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 3: Long-term - Mobile App Development
      Task(
        id: 'task-3',
        name: 'Mobile App Development',
        deadline: now.add(const Duration(days: 15)),
        workSteps: [
          WorkStep(
            id: 'ws-7',
            taskId: 'task-3',
            name: 'UI/UX Design',
            durationHours: 8,
            role: 'Designer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-8',
            taskId: 'task-3',
            name: 'Backend API',
            durationHours: 16,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-9',
            taskId: 'task-3',
            name: 'Frontend Development',
            durationHours: 20,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 3,
          ),
          WorkStep(
            id: 'ws-10',
            taskId: 'task-3',
            name: 'Testing & QA',
            durationHours: 8,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 4,
          ),
        ],
      ),

      // Task 4: Urgent - API Documentation
      Task(
        id: 'task-4',
        name: 'API Documentation',
        deadline: now.add(const Duration(hours: 6)),
        workSteps: [
          WorkStep(
            id: 'ws-11',
            taskId: 'task-4',
            name: 'Write API specs',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-12',
            taskId: 'task-4',
            name: 'Review documentation',
            durationHours: 2,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
        ],
      ),

      // Task 5: Medium - Security Audit
      Task(
        id: 'task-5',
        name: 'Security Audit',
        deadline: now.add(const Duration(days: 7)),
        workSteps: [
          WorkStep(
            id: 'ws-13',
            taskId: 'task-5',
            name: 'Code review',
            durationHours: 6,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-14',
            taskId: 'task-5',
            name: 'Penetration testing',
            durationHours: 8,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-15',
            taskId: 'task-5',
            name: 'Fix vulnerabilities',
            durationHours: 10,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 6: Long-term - Performance Optimization
      Task(
        id: 'task-6',
        name: 'Performance Optimization',
        deadline: now.add(const Duration(days: 20)),
        workSteps: [
          WorkStep(
            id: 'ws-16',
            taskId: 'task-6',
            name: 'Performance analysis',
            durationHours: 8,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-17',
            taskId: 'task-6',
            name: 'Optimize database queries',
            durationHours: 12,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-18',
            taskId: 'task-6',
            name: 'Frontend optimization',
            durationHours: 6,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 7: Medium - User Authentication System
      Task(
        id: 'task-7',
        name: 'User Authentication System',
        deadline: now.add(const Duration(days: 5)),
        workSteps: [
          WorkStep(
            id: 'ws-19',
            taskId: 'task-7',
            name: 'Design auth flow',
            durationHours: 4,
            role: 'Designer',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-20',
            taskId: 'task-7',
            name: 'Implement OAuth',
            durationHours: 10,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-21',
            taskId: 'task-7',
            name: 'Security testing',
            durationHours: 6,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 8: Urgent - Bug Fixes
      Task(
        id: 'task-8',
        name: 'Critical Bug Fixes',
        deadline: now.add(const Duration(hours: 12)),
        workSteps: [
          WorkStep(
            id: 'ws-22',
            taskId: 'task-8',
            name: 'Identify bugs',
            durationHours: 2,
            role: 'QA Engineer',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-3',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-23',
            taskId: 'task-8',
            name: 'Fix critical issues',
            durationHours: 6,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-24',
            taskId: 'task-8',
            name: 'Verify fixes',
            durationHours: 2,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 9: Long-term - CI/CD Pipeline
      Task(
        id: 'task-9',
        name: 'CI/CD Pipeline Setup',
        deadline: now.add(const Duration(days: 10)),
        workSteps: [
          WorkStep(
            id: 'ws-25',
            taskId: 'task-9',
            name: 'Configure build pipeline',
            durationHours: 8,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-26',
            taskId: 'task-9',
            name: 'Setup deployment automation',
            durationHours: 10,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-27',
            taskId: 'task-9',
            name: 'Test pipeline',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // Task 10: Medium - Feature Enhancement
      Task(
        id: 'task-10',
        name: 'Dashboard Feature Enhancement',
        deadline: now.add(const Duration(days: 4)),
        workSteps: [
          WorkStep(
            id: 'ws-28',
            taskId: 'task-10',
            name: 'Design new features',
            durationHours: 6,
            role: 'Designer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-29',
            taskId: 'task-10',
            name: 'Implement features',
            durationHours: 12,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-30',
            taskId: 'task-10',
            name: 'User acceptance testing',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),
    ];

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

    print('Auto-completed: ${stepToComplete.name} from task ${stepToComplete.taskId}');
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
        // Include ALL work steps assigned to actor (including completed ones)
        // Like Jira/Trello - completed items stay visible
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
    await Future.delayed(const Duration(milliseconds: 300));

    // Find task and work step
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final stepIndex = task.workSteps.indexWhere((ws) => ws.id == workStepId);

      if (stepIndex != -1) {
        final step = task.workSteps[stepIndex];

        // Update status to completed
        final updatedStep = step.copyWith(status: WorkStepStatus.completed);

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
  Future<Task> createTask(String name, DateTime deadline, List<WorkStep> workSteps, {List<SubTask>? subTasks, String? assignedToActorId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newTaskId = 'task-${_tasks.length + 1}';
    final newTask = Task(
      id: newTaskId,
      name: name,
      deadline: deadline,
      workSteps: workSteps.map((ws) => ws.copyWith(
        id: 'ws-${DateTime.now().millisecondsSinceEpoch}-${ws.sequenceOrder}',
        taskId: newTaskId,
      )).toList(),
      subTasks: subTasks?.map((st) => st.copyWith(
        id: 'st-${DateTime.now().millisecondsSinceEpoch}-${st.sequenceOrder}',
        taskId: newTaskId,
      )).toList() ?? [],
      assignedToActorId: assignedToActorId,
    );
    
    _tasks.add(newTask);
    _tasksSubject.add(_tasks);
    
    return newTask;
  }

  @override
  Future<void> addSubTask(String taskId, SubTask subTask) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id == taskId) {
        final task = _tasks[i];
        final updatedSubTasks = List<SubTask>.from(task.subTasks)..add(subTask);
        _tasks[i] = task.copyWith(subTasks: updatedSubTasks);
        break;
      }
    }
    
    _tasksSubject.add(_tasks);
  }

  @override
  Future<void> completeSubTask(String subTaskId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final subTaskIndex = task.subTasks.indexWhere((st) => st.id == subTaskId);
      if (subTaskIndex != -1) {
        final subTask = task.subTasks[subTaskIndex];
        final updatedSubTask = subTask.copyWith(status: WorkStepStatus.completed);
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
  void dispose() {
    _autoCompleteTimer?.cancel();
    _tasksSubject.close();
  }
}

