import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../interfaces/i_notification_service.dart';
import '../../models/task.dart';
import '../../models/work_step.dart';

/// Mock notification service implementing real-time updates
/// Fulfills requirement: Usability III - automatic updates without user interaction
class MockNotificationService implements INotificationService {
  final _taskUpdatesSubject = BehaviorSubject<Task>();
  final _workStepCompletionsSubject = BehaviorSubject<WorkStep>();
  final _priorityChangesSubject = BehaviorSubject<WorkStep>();

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
  void notifyWorkStepCompleted(WorkStep workStep, Task task) {
    _workStepCompletionsSubject.add(workStep);
    _taskUpdatesSubject.add(task);
  }

  @override
  void notifyPriorityChanged(WorkStep workStep) {
    _priorityChangesSubject.add(workStep);
  }

  @override
  void dispose() {
    _taskUpdatesSubject.close();
    _workStepCompletionsSubject.close();
    _priorityChangesSubject.close();
  }
}

