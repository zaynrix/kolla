import '../../models/task.dart';
import '../../models/work_step.dart';
import '../../models/enums.dart';

abstract class ITaskService {
  Future<List<Task>> getAllTasks();
  Stream<List<Task>> watchAllTasks();
  Future<List<WorkStep>> getActorWorkSteps(String actorId);
  Stream<List<WorkStep>> watchActorWorkSteps(String actorId);
  Future<void> completeWorkStep(String workStepId);
  Future<void> updateWorkStepPriority(String workStepId, Priority priority);
  Future<Task> getTask(String taskId);
  Future<Task> createTask(String name, DateTime deadline, List<WorkStep> workSteps);
  void dispose();
}

