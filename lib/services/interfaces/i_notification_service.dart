import '../../models/task.dart';
import '../../models/work_step.dart';
import '../../models/notification.dart' as models;

/// Notification service interface for real-time updates
/// Implements requirement: Usability III - automatic updates and notifications
abstract class INotificationService {
  /// Stream of task updates for workflow manager
  Stream<Task> watchTaskUpdates(String taskId);
  
  /// Stream of work step completions
  Stream<WorkStep> watchWorkStepCompletions();
  
  /// Stream of priority changes
  Stream<WorkStep> watchPriorityChanges();
  
  /// Stream of all notifications
  Stream<List<models.Notification>> watchNotifications();
  
  /// Notify about work step completion
  void notifyWorkStepCompleted(WorkStep workStep, Task task);
  
  /// Notify about priority change
  void notifyPriorityChanged(WorkStep workStep);
  
  /// Mark notification as read
  void markAsRead(String notificationId);
  
  /// Dismiss/delete notification
  void dismissNotification(String notificationId);
  
  /// Mark all notifications as read
  void markAllAsRead();
  
  /// Clear all notifications
  void clearAll();
  
  void dispose();
}

