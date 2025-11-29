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
      // ============================================
      // TASK 1: URGENT - Website Redesign Project
      // ============================================
      Task(
        id: 'task-1',
        name: 'Website Redesign Project',
        description: 'Complete redesign of the company website with modern UI/UX. '
            'This includes new branding, responsive design, and improved user experience. '
            'The new design should align with our brand guidelines and be mobile-first.',
        deadline: now.add(const Duration(hours: 16)),
        assignedToActorId: 'actor-1',
        workSteps: [
          WorkStep(
            id: 'ws-1',
            taskId: 'task-1',
            name: 'Create design mockups and wireframes',
            durationHours: 4,
            role: 'Designer',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-2',
            taskId: 'task-1',
            name: 'Implement frontend components',
            durationHours: 8,
            role: 'Developer',
            status: WorkStepStatus.inProgress,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-3',
            taskId: 'task-1',
            name: 'Perform QA testing and bug fixes',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-1-1',
            taskId: 'task-1',
            name: 'Review brand guidelines',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-1-2',
            taskId: 'task-1',
            name: 'Create color palette',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-2',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-1-3',
            taskId: 'task-1',
            name: 'Design homepage layout',
            status: WorkStepStatus.inProgress,
            assignedToActorId: 'actor-2',
            sequenceOrder: 3,
          ),
          SubTask(
            id: 'st-1-4',
            taskId: 'task-1',
            name: 'Implement responsive navigation',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 4,
          ),
        ],
      ),

      // ============================================
      // TASK 2: MEDIUM PRIORITY - Database Migration
      // ============================================
      Task(
        id: 'task-2',
        name: 'Database Migration to PostgreSQL',
        description: 'Migrate the existing MySQL database to PostgreSQL for better performance '
            'and scalability. This is a critical infrastructure change that requires careful '
            'planning and testing to avoid data loss.',
        deadline: now.add(const Duration(days: 3)),
        assignedToActorId: 'actor-4',
        workSteps: [
          WorkStep(
            id: 'ws-4',
            taskId: 'task-2',
            name: 'Create full database backup',
            durationHours: 2,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-5',
            taskId: 'task-2',
            name: 'Write and test migration scripts',
            durationHours: 6,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-6',
            taskId: 'task-2',
            name: 'Validate migrated data integrity',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-2-1',
            taskId: 'task-2',
            name: 'Set up PostgreSQL server',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-2-2',
            taskId: 'task-2',
            name: 'Map MySQL schema to PostgreSQL',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
        ],
      ),

      // ============================================
      // TASK 3: LONG-TERM - Mobile App Development
      // ============================================
      Task(
        id: 'task-3',
        name: 'Mobile App Development - iOS & Android',
        description: 'Develop a cross-platform mobile application for both iOS and Android. '
            'The app should provide core functionality of our web platform with native performance. '
            'Focus on user experience and offline capabilities.',
        deadline: now.add(const Duration(days: 15)),
        assignedToActorId: 'actor-5',
        workSteps: [
          WorkStep(
            id: 'ws-7',
            taskId: 'task-3',
            name: 'Design mobile UI/UX mockups',
            durationHours: 8,
            role: 'Designer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-8',
            taskId: 'task-3',
            name: 'Develop backend API endpoints',
            durationHours: 16,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-9',
            taskId: 'task-3',
            name: 'Build mobile app frontend',
            durationHours: 20,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 3,
          ),
          WorkStep(
            id: 'ws-10',
            taskId: 'task-3',
            name: 'Comprehensive testing on both platforms',
            durationHours: 8,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 4,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-3-1',
            taskId: 'task-3',
            name: 'Research Flutter vs React Native',
            status: WorkStepStatus.completed,
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-3-2',
            taskId: 'task-3',
            name: 'Set up development environment',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-3-3',
            taskId: 'task-3',
            name: 'Create app icon and splash screen',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-2',
            sequenceOrder: 3,
          ),
        ],
      ),

      // ============================================
      // TASK 4: URGENT - API Documentation
      // ============================================
      Task(
        id: 'task-4',
        name: 'Complete API Documentation',
        description: 'Document all REST API endpoints with clear examples, request/response formats, '
            'and error codes. This documentation is needed for the frontend team and external partners.',
        deadline: now.add(const Duration(hours: 6)),
        assignedToActorId: 'actor-1',
        workSteps: [
          WorkStep(
            id: 'ws-11',
            taskId: 'task-4',
            name: 'Write API specification document',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-12',
            taskId: 'task-4',
            name: 'Review and approve documentation',
            durationHours: 2,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-4-1',
            taskId: 'task-4',
            name: 'List all API endpoints',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-4-2',
            taskId: 'task-4',
            name: 'Add request/response examples',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
        ],
      ),

      // ============================================
      // TASK 5: MEDIUM - Security Audit
      // ============================================
      Task(
        id: 'task-5',
        name: 'Security Audit and Vulnerability Assessment',
        description: 'Conduct a comprehensive security audit of the entire system. '
            'Identify vulnerabilities, perform penetration testing, and fix critical security issues. '
            'This is required for compliance and customer trust.',
        deadline: now.add(const Duration(days: 7)),
        assignedToActorId: 'actor-4',
        workSteps: [
          WorkStep(
            id: 'ws-13',
            taskId: 'task-5',
            name: 'Perform code security review',
            durationHours: 6,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-14',
            taskId: 'task-5',
            name: 'Execute penetration testing',
            durationHours: 8,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-15',
            taskId: 'task-5',
            name: 'Fix identified vulnerabilities',
            durationHours: 10,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-5-1',
            taskId: 'task-5',
            name: 'Set up security scanning tools',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-5-2',
            taskId: 'task-5',
            name: 'Review authentication mechanisms',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-5-3',
            taskId: 'task-5',
            name: 'Check for SQL injection vulnerabilities',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 3,
          ),
        ],
      ),

      // ============================================
      // TASK 6: LONG-TERM - Performance Optimization
      // ============================================
      Task(
        id: 'task-6',
        name: 'Application Performance Optimization',
        description: 'Optimize application performance to improve load times and user experience. '
            'Focus on database queries, frontend rendering, and API response times. '
            'Target: 50% improvement in page load times.',
        deadline: now.add(const Duration(days: 20)),
        assignedToActorId: 'actor-1',
        workSteps: [
          WorkStep(
            id: 'ws-16',
            taskId: 'task-6',
            name: 'Analyze current performance bottlenecks',
            durationHours: 8,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-17',
            taskId: 'task-6',
            name: 'Optimize slow database queries',
            durationHours: 12,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-18',
            taskId: 'task-6',
            name: 'Implement frontend caching and lazy loading',
            durationHours: 6,
            role: 'Developer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-6-1',
            taskId: 'task-6',
            name: 'Set up performance monitoring',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-6-2',
            taskId: 'task-6',
            name: 'Identify top 10 slowest queries',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 2,
          ),
        ],
      ),

      // ============================================
      // TASK 7: MEDIUM - User Authentication System
      // ============================================
      Task(
        id: 'task-7',
        name: 'Implement OAuth2 Authentication System',
        description: 'Replace the current basic authentication with OAuth2. '
            'Support multiple providers (Google, GitHub, Microsoft) and implement '
            'secure token management with refresh tokens.',
        deadline: now.add(const Duration(days: 5)),
        assignedToActorId: 'actor-1',
        workSteps: [
          WorkStep(
            id: 'ws-19',
            taskId: 'task-7',
            name: 'Design authentication flow and user experience',
            durationHours: 4,
            role: 'Designer',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-20',
            taskId: 'task-7',
            name: 'Implement OAuth2 integration',
            durationHours: 10,
            role: 'Developer',
            status: WorkStepStatus.inProgress,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-21',
            taskId: 'task-7',
            name: 'Security testing and validation',
            durationHours: 6,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-7-1',
            taskId: 'task-7',
            name: 'Register OAuth apps with providers',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-7-2',
            taskId: 'task-7',
            name: 'Implement Google OAuth',
            status: WorkStepStatus.inProgress,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-7-3',
            taskId: 'task-7',
            name: 'Implement GitHub OAuth',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 3,
          ),
          SubTask(
            id: 'st-7-4',
            taskId: 'task-7',
            name: 'Add refresh token mechanism',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 4,
          ),
        ],
      ),

      // ============================================
      // TASK 8: URGENT - Critical Bug Fixes
      // ============================================
      Task(
        id: 'task-8',
        name: 'Fix Critical Production Bugs',
        description: 'Address critical bugs reported in production that are affecting users. '
            'Priority: Fix payment processing issue and data export bug. '
            'These issues need immediate attention to prevent revenue loss.',
        deadline: now.add(const Duration(hours: 12)),
        assignedToActorId: 'actor-1',
        workSteps: [
          WorkStep(
            id: 'ws-22',
            taskId: 'task-8',
            name: 'Identify and reproduce reported bugs',
            durationHours: 2,
            role: 'QA Engineer',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-3',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-23',
            taskId: 'task-8',
            name: 'Fix critical payment processing bug',
            durationHours: 6,
            role: 'Developer',
            status: WorkStepStatus.inProgress,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-24',
            taskId: 'task-8',
            name: 'Verify fixes and deploy hotfix',
            durationHours: 2,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-8-1',
            taskId: 'task-8',
            name: 'Fix payment gateway integration',
            status: WorkStepStatus.inProgress,
            assignedToActorId: 'actor-1',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-8-2',
            taskId: 'task-8',
            name: 'Fix data export CSV bug',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-1',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-8-3',
            taskId: 'task-8',
            name: 'Test payment flow end-to-end',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // ============================================
      // TASK 9: LONG-TERM - CI/CD Pipeline Setup
      // ============================================
      Task(
        id: 'task-9',
        name: 'Set Up CI/CD Pipeline',
        description: 'Implement a complete CI/CD pipeline for automated testing, building, '
            'and deployment. This will improve development workflow and reduce deployment errors. '
            'Use GitHub Actions or Jenkins for automation.',
        deadline: now.add(const Duration(days: 10)),
        assignedToActorId: 'actor-4',
        workSteps: [
          WorkStep(
            id: 'ws-25',
            taskId: 'task-9',
            name: 'Configure automated build pipeline',
            durationHours: 8,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-26',
            taskId: 'task-9',
            name: 'Set up automated deployment to staging',
            durationHours: 10,
            role: 'DevOps',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-27',
            taskId: 'task-9',
            name: 'Test and validate pipeline',
            durationHours: 4,
            role: 'QA Engineer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
        subTasks: [
          SubTask(
            id: 'st-9-1',
            taskId: 'task-9',
            name: 'Choose CI/CD platform',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-4',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-9-2',
            taskId: 'task-9',
            name: 'Write deployment scripts',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-4',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-9-3',
            taskId: 'task-9',
            name: 'Set up automated testing in pipeline',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-3',
            sequenceOrder: 3,
          ),
        ],
      ),

      // ============================================
      // TASK 10: MEDIUM - Dashboard Feature Enhancement
      // ============================================
      Task(
        id: 'task-10',
        name: 'Enhance User Dashboard with Analytics',
        description: 'Add new analytics features to the user dashboard including charts, '
            'reports, and data visualization. Users should be able to track their activity, '
            'view statistics, and export reports.',
        deadline: now.add(const Duration(days: 4)),
        assignedToActorId: 'actor-5',
        workSteps: [
          WorkStep(
            id: 'ws-28',
            taskId: 'task-10',
            name: 'Design new dashboard features and layouts',
            durationHours: 6,
            role: 'Designer',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-2',
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-29',
            taskId: 'task-10',
            name: 'Implement analytics components and charts',
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
        subTasks: [
          SubTask(
            id: 'st-10-1',
            taskId: 'task-10',
            name: 'Research charting libraries',
            status: WorkStepStatus.completed,
            assignedToActorId: 'actor-5',
            sequenceOrder: 1,
          ),
          SubTask(
            id: 'st-10-2',
            taskId: 'task-10',
            name: 'Create activity timeline component',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
            sequenceOrder: 2,
          ),
          SubTask(
            id: 'st-10-3',
            taskId: 'task-10',
            name: 'Add export to PDF functionality',
            status: WorkStepStatus.pending,
            assignedToActorId: 'actor-5',
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
  Future<Task> createTask(String name, DateTime deadline, List<WorkStep> workSteps, {List<SubTask>? subTasks, String? assignedToActorId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newTaskId = 'task-${_tasks.length + 1}';
    final newTask = Task(
      id: newTaskId,
      name: name,
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
