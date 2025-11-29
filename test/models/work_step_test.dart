import 'package:flutter_test/flutter_test.dart';
import 'package:kolla/models/work_step.dart';
import 'package:kolla/models/enums.dart';

void main() {
  group('WorkStep Priority Calculation', () {
    test('should return immediate priority when deadline is ≤ 8 hours', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(hours: 6)); // 6 hours from now
      
      const workStep = WorkStep(
        id: 'ws-1',
        taskId: 'task-1',
        name: 'Test Step',
        durationHours: 4,
        role: 'Developer',
        status: WorkStepStatus.pending,
        sequenceOrder: 1,
      );

      final priority = workStep.calculateAutoPriority(deadline, 0);
      expect(priority, Priority.immediate);
    });

    test('should return medium priority when deadline is > 8 and ≤ 32 hours', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(hours: 20)); // 20 hours from now
      
      const workStep = WorkStep(
        id: 'ws-1',
        taskId: 'task-1',
        name: 'Test Step',
        durationHours: 4,
        role: 'Developer',
        status: WorkStepStatus.pending,
        sequenceOrder: 1,
      );

      final priority = workStep.calculateAutoPriority(deadline, 0);
      expect(priority, Priority.medium);
    });

    test('should return longTerm priority when deadline is > 32 hours', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 2)); // 48 hours from now
      
      const workStep = WorkStep(
        id: 'ws-1',
        taskId: 'task-1',
        name: 'Test Step',
        durationHours: 4,
        role: 'Developer',
        status: WorkStepStatus.pending,
        sequenceOrder: 1,
      );

      final priority = workStep.calculateAutoPriority(deadline, 0);
      expect(priority, Priority.longTerm);
    });

    test('should use manual priority when set', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(hours: 6)); // Would be immediate
      
      const workStep = WorkStep(
        id: 'ws-1',
        taskId: 'task-1',
        name: 'Test Step',
        durationHours: 4,
        role: 'Developer',
        status: WorkStepStatus.pending,
        manualPriority: Priority.longTerm, // Manual override
        sequenceOrder: 1,
      );

      final priority = workStep.getEffectivePriority(deadline, 0);
      expect(priority, Priority.longTerm); // Should use manual priority
    });
  });
}

