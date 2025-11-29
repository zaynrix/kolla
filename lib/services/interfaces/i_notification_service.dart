import '../../models/task.dart';
import '../../models/work_step.dart';

/// Notification service interface for real-time updates
/// Implements requirement: Usability III - automatic updates and notifications
abstract class INotificationService {
  /// Stream of task updates for workflow manager
  Stream<Task> watchTaskUpdates(String taskId);
  
  /// Stream of work step completions
  Stream<WorkStep> watchWorkStepCompletions();
  
  /// Stream of priority changes
  Stream<WorkStep> watchPriorityChanges();
  
  /// Notify about work step completion
  void notifyWorkStepCompleted(WorkStep workStep, Task task);
  
  /// Notify about priority change
  void notifyPriorityChanged(WorkStep workStep);
  
  void dispose();
}

