import '../../../models/task.dart';
import '../../../models/work_step.dart';
import '../../../models/subtask.dart';
import '../../../models/enums.dart';

/// Factory Pattern for creating mock task data
/// Single Responsibility: Generate mock task data
/// Separation of Concerns: Data generation separated from service logic
class MockTaskDataFactory {
  static List<Task> createMockTasks(DateTime now) {
    return [
      _createWebsiteRedesignTask(now),
      _createDatabaseMigrationTask(now),
      _createMobileAppTask(now),
      _createAPIDocumentationTask(now),
      _createSecurityAuditTask(now),
      _createPerformanceOptimizationTask(now),
      _createUserTestingTask(now),
      _createContentManagementTask(now),
      _createIntegrationTask(now),
      _createDeploymentTask(now),
    ];
  }

  static Task _createWebsiteRedesignTask(DateTime now) {
    return Task(
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
          name: 'Develop frontend components',
          durationHours: 8,
          role: 'Developer',
          status: WorkStepStatus.inProgress,
          assignedToActorId: 'actor-1',
          sequenceOrder: 2,
        ),
        WorkStep(
          id: 'ws-3',
          taskId: 'task-1',
          name: 'Integrate backend APIs',
          durationHours: 6,
          role: 'Developer',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-5',
          sequenceOrder: 3,
        ),
        WorkStep(
          id: 'ws-4',
          taskId: 'task-1',
          name: 'Conduct user acceptance testing',
          durationHours: 4,
          role: 'QA Engineer',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-3',
          sequenceOrder: 4,
        ),
      ],
      subTasks: [
        SubTask(
          id: 'st-1-1',
          taskId: 'task-1',
          name: 'Research competitor designs',
          status: WorkStepStatus.completed,
          assignedToActorId: 'actor-2',
          sequenceOrder: 1,
        ),
        SubTask(
          id: 'st-1-2',
          taskId: 'task-1',
          name: 'Gather user feedback for current site',
          status: WorkStepStatus.inProgress,
          assignedToActorId: 'actor-2',
          sequenceOrder: 2,
        ),
        SubTask(
          id: 'st-1-3',
          taskId: 'task-1',
          name: 'Optimize images for web',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-1',
          sequenceOrder: 3,
        ),
        SubTask(
          id: 'st-1-4',
          taskId: 'task-1',
          name: 'Implement dark mode toggle',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-5',
          sequenceOrder: 4,
        ),
      ],
    );
  }

  static Task _createDatabaseMigrationTask(DateTime now) {
    return Task(
      id: 'task-2',
      name: 'Database Migration to PostgreSQL',
      description: 'Migrate the existing MySQL database to PostgreSQL for better performance and scalability. '
          'This includes schema migration, data transfer, and validation.',
      deadline: now.add(const Duration(days: 3)),
      assignedToActorId: 'actor-4',
      workSteps: [
        WorkStep(
          id: 'ws-5',
          taskId: 'task-2',
          name: 'Backup current database',
          durationHours: 2,
          role: 'DevOps',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-4',
          sequenceOrder: 1,
        ),
        WorkStep(
          id: 'ws-6',
          taskId: 'task-2',
          name: 'Create PostgreSQL schema',
          durationHours: 6,
          role: 'Developer',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-1',
          sequenceOrder: 2,
        ),
        WorkStep(
          id: 'ws-7',
          taskId: 'task-2',
          name: 'Migrate data and validate',
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
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-4',
          sequenceOrder: 1,
        ),
        SubTask(
          id: 'st-2-2',
          taskId: 'task-2',
          name: 'Document migration process',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-1',
          sequenceOrder: 2,
        ),
      ],
    );
  }

  // Add more task creation methods...
  static Task _createMobileAppTask(DateTime now) {
    return Task(
      id: 'task-3',
      name: 'Mobile App Development',
      description: 'Develop a cross-platform mobile application using Flutter.',
      deadline: now.add(const Duration(days: 15)),
      assignedToActorId: 'actor-1',
      workSteps: [
        WorkStep(
          id: 'ws-8',
          taskId: 'task-3',
          name: 'UI/UX Design',
          durationHours: 8,
          role: 'Designer',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-2',
          sequenceOrder: 1,
        ),
        WorkStep(
          id: 'ws-9',
          taskId: 'task-3',
          name: 'Backend API Integration',
          durationHours: 16,
          role: 'Developer',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-1',
          sequenceOrder: 2,
        ),
      ],
      subTasks: [],
    );
  }

  static Task _createAPIDocumentationTask(DateTime now) {
    return Task(
      id: 'task-4',
      name: 'API Documentation',
      description: 'Create comprehensive API documentation.',
      deadline: now.add(const Duration(hours: 6)),
      assignedToActorId: 'actor-1',
      workSteps: [
        WorkStep(
          id: 'ws-10',
          taskId: 'task-4',
          name: 'Write API specs',
          durationHours: 4,
          role: 'Developer',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-1',
          sequenceOrder: 1,
        ),
      ],
      subTasks: [],
    );
  }

  static Task _createSecurityAuditTask(DateTime now) {
    return Task(
      id: 'task-5',
      name: 'Security Audit',
      description: 'Conduct comprehensive security audit.',
      deadline: now.add(const Duration(days: 7)),
      assignedToActorId: 'actor-4',
      workSteps: [
        WorkStep(
          id: 'ws-11',
          taskId: 'task-5',
          name: 'Code review',
          durationHours: 6,
          role: 'Security Specialist',
          status: WorkStepStatus.pending,
          assignedToActorId: 'actor-4',
          sequenceOrder: 1,
        ),
      ],
      subTasks: [],
    );
  }

  static Task _createPerformanceOptimizationTask(DateTime now) {
    return Task(
      id: 'task-6',
      name: 'Performance Optimization',
      description: 'Optimize application performance.',
      deadline: now.add(const Duration(days: 5)),
      assignedToActorId: 'actor-1',
      workSteps: [],
      subTasks: [],
    );
  }

  static Task _createUserTestingTask(DateTime now) {
    return Task(
      id: 'task-7',
      name: 'User Testing',
      description: 'Conduct user testing sessions.',
      deadline: now.add(const Duration(days: 10)),
      assignedToActorId: 'actor-3',
      workSteps: [],
      subTasks: [],
    );
  }

  static Task _createContentManagementTask(DateTime now) {
    return Task(
      id: 'task-8',
      name: 'Content Management System',
      description: 'Implement CMS features.',
      deadline: now.add(const Duration(days: 12)),
      assignedToActorId: 'actor-1',
      workSteps: [],
      subTasks: [],
    );
  }

  static Task _createIntegrationTask(DateTime now) {
    return Task(
      id: 'task-9',
      name: 'Third-party Integration',
      description: 'Integrate third-party services.',
      deadline: now.add(const Duration(days: 8)),
      assignedToActorId: 'actor-1',
      workSteps: [],
      subTasks: [],
    );
  }

  static Task _createDeploymentTask(DateTime now) {
    return Task(
      id: 'task-10',
      name: 'Production Deployment',
      description: 'Deploy application to production.',
      deadline: now.add(const Duration(days: 20)),
      assignedToActorId: 'actor-4',
      workSteps: [],
      subTasks: [],
    );
  }
}

