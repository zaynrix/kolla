import 'package:flutter_test/flutter_test.dart';
import 'package:kolla/models/task.dart';
import 'package:kolla/models/work_step.dart';
import 'package:kolla/models/enums.dart';

void main() {
  group('Task Computed Properties', () {
    test('should calculate completed steps count correctly', () {
      final task = Task(
        id: 'task-1',
        name: 'Test Task',
        deadline: DateTime.now().add(const Duration(days: 1)),
        workSteps: [
          WorkStep(
            id: 'ws-1',
            taskId: 'task-1',
            name: 'Step 1',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.completed,
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-2',
            taskId: 'task-1',
            name: 'Step 2',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            sequenceOrder: 2,
          ),
        ],
      );

      expect(task.completedStepsCount, 1);
      expect(task.remainingStepsCount, 1);
      expect(task.progressPercentage, 50.0);
    });

    test('should return overdue status when deadline passed', () {
      final task = Task(
        id: 'task-1',
        name: 'Test Task',
        deadline: DateTime.now().subtract(const Duration(hours: 1)),
        workSteps: [
          WorkStep(
            id: 'ws-1',
            taskId: 'task-1',
            name: 'Step 1',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            sequenceOrder: 1,
          ),
        ],
      );

      expect(task.status, TaskStatus.overdue);
    });

    test('should return atRisk status when deadline close and many steps remaining', () {
      final task = Task(
        id: 'task-1',
        name: 'Test Task',
        deadline: DateTime.now().add(const Duration(hours: 20)),
        workSteps: [
          WorkStep(
            id: 'ws-1',
            taskId: 'task-1',
            name: 'Step 1',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            sequenceOrder: 1,
          ),
          WorkStep(
            id: 'ws-2',
            taskId: 'task-1',
            name: 'Step 2',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            sequenceOrder: 2,
          ),
          WorkStep(
            id: 'ws-3',
            taskId: 'task-1',
            name: 'Step 3',
            durationHours: 4,
            role: 'Developer',
            status: WorkStepStatus.pending,
            sequenceOrder: 3,
          ),
        ],
      );

      expect(task.status, TaskStatus.atRisk);
    });
  });
}

