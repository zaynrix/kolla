import '../models/enums.dart';
import '../models/work_step.dart';
import '../models/task.dart';

class PriorityCalculator {
  static Priority calculateWorkStepPriority(
    WorkStep workStep,
    Task task,
  ) {
    final remainingSteps = task.workSteps
        .where((ws) =>
            ws.sequenceOrder > workStep.sequenceOrder &&
            ws.status != WorkStepStatus.completed)
        .length;

    return workStep.getEffectivePriority(task.deadline, remainingSteps);
  }

  static List<WorkStep> sortByPriority(
    List<WorkStep> workSteps,
    List<Task> tasks,
  ) {
    final sorted = List<WorkStep>.from(workSteps);
    sorted.sort((a, b) {
      final taskA = tasks.firstWhere((t) => t.id == a.taskId);
      final taskB = tasks.firstWhere((t) => t.id == b.taskId);

      final priorityA = calculateWorkStepPriority(a, taskA);
      final priorityB = calculateWorkStepPriority(b, taskB);

      return priorityA.index.compareTo(priorityB.index);
    });

    return sorted;
  }
}

