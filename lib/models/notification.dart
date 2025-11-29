import 'work_step.dart';
import 'task.dart';
import 'enums.dart';

/// Notification model for real-time updates
/// Single Responsibility: Represent a notification in the system
class Notification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? workStepId;
  final String? taskId;
  final String? actorId; // Actor who triggered the notification

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.workStepId,
    this.taskId,
    this.actorId,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? workStepId,
    String? taskId,
    String? actorId,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      workStepId: workStepId ?? this.workStepId,
      taskId: taskId ?? this.taskId,
      actorId: actorId ?? this.actorId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'workStepId': workStepId,
      'taskId': taskId,
      'actorId': actorId,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      workStepId: json['workStepId'] as String?,
      taskId: json['taskId'] as String?,
      actorId: json['actorId'] as String?,
    );
  }
}

