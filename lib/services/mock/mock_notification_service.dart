import 'dart:async';
import 'package:rxdart/rxdart.dart' hide Notification;
import '../interfaces/i_notification_service.dart';
import '../../models/task.dart';
import '../../models/work_step.dart';
import '../../models/notification.dart' as models;
import '../../models/enums.dart';

/// Mock notification service implementing real-time updates
/// Fulfills requirement: Usability III - automatic updates without user interaction
class MockNotificationService implements INotificationService {
  final _taskUpdatesSubject = BehaviorSubject<Task>();
  final _workStepCompletionsSubject = BehaviorSubject<WorkStep>();
  final _priorityChangesSubject = BehaviorSubject<WorkStep>();
  final _notificationsSubject = BehaviorSubject<List<models.Notification>>.seeded([]);
  
  final List<models.Notification> _notifications = [];
  int _notificationIdCounter = 1;

  MockNotificationService() {
    _notificationsSubject.add(_notifications);
  }

  @override
  Stream<Task> watchTaskUpdates(String taskId) {
    return _taskUpdatesSubject.stream.where((task) => task.id == taskId);
  }

  @override
  Stream<WorkStep> watchWorkStepCompletions() {
    return _workStepCompletionsSubject.stream;
  }

  @override
  Stream<WorkStep> watchPriorityChanges() {
    return _priorityChangesSubject.stream;
  }

  @override
  Stream<List<models.Notification>> watchNotifications() {
    return _notificationsSubject.stream;
  }

  @override
  void notifyWorkStepCompleted(WorkStep workStep, Task task) {
    _workStepCompletionsSubject.add(workStep);
    _taskUpdatesSubject.add(task);
    
    // Create notification
    final notification = models.Notification(
      id: 'notif-${_notificationIdCounter++}',
      title: 'Work Step Completed',
      message: '${workStep.name} in task "${task.name}" has been completed',
      type: NotificationType.workStepCompleted,
      timestamp: DateTime.now(),
      workStepId: workStep.id,
      taskId: task.id,
      actorId: workStep.assignedToActorId,
    );
    _notifications.insert(0, notification);
    _notificationsSubject.add(List.from(_notifications));
  }

  @override
  void notifyPriorityChanged(WorkStep workStep) {
    _priorityChangesSubject.add(workStep);
    
    // Find task for work step
    // Note: In real implementation, we'd need access to task service
    // For now, create a generic notification
    final notification = models.Notification(
      id: 'notif-${_notificationIdCounter++}',
      title: 'Priority Changed',
      message: 'Priority for "${workStep.name}" has been updated',
      type: NotificationType.priorityChanged,
      timestamp: DateTime.now(),
      workStepId: workStep.id,
      actorId: workStep.assignedToActorId,
    );
    _notifications.insert(0, notification);
    _notificationsSubject.add(List.from(_notifications));
  }

  @override
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsSubject.add(List.from(_notifications));
    }
  }

  @override
  void dismissNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsSubject.add(List.from(_notifications));
  }

  @override
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _notificationsSubject.add(List.from(_notifications));
  }

  @override
  void clearAll() {
    _notifications.clear();
    _notificationsSubject.add(List.from(_notifications));
  }

  @override
  void dispose() {
    _taskUpdatesSubject.close();
    _workStepCompletionsSubject.close();
    _priorityChangesSubject.close();
    _notificationsSubject.close();
  }
}

