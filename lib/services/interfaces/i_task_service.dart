import '../../models/task.dart';
import '../../models/work_step.dart';
import '../../models/subtask.dart';
import '../../models/enums.dart';

abstract class ITaskService {
  Future<List<Task>> getAllTasks();
  Stream<List<Task>> watchAllTasks();
  Future<List<WorkStep>> getActorWorkSteps(String actorId);
  Stream<List<WorkStep>> watchActorWorkSteps(String actorId);
  Future<void> completeWorkStep(String workStepId);
  Future<void> updateWorkStepStatus(String workStepId, WorkStepStatus status);
  Future<void> updateWorkStepPriority(String workStepId, Priority priority);
  Future<Task> getTask(String taskId);
  Future<Task> createTask(String name, DateTime deadline, List<WorkStep> workSteps, {List<SubTask>? subTasks, String? assignedToActorId});
  Future<Task> updateTask(Task task);
  Future<void> addSubTask(String taskId, SubTask subTask);
  Future<void> completeSubTask(String subTaskId);
  Future<void> assignTask(String taskId, String actorId);
  void dispose();
}

