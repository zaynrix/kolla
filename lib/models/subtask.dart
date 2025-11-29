import 'enums.dart';

class SubTask {
  final String id;
  final String taskId;
  final String name;
  final WorkStepStatus status;
  final String? assignedToActorId;
  final int sequenceOrder;

  const SubTask({
    required this.id,
    required this.taskId,
    required this.name,
    required this.status,
    this.assignedToActorId,
    required this.sequenceOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'name': name,
      'status': status.toString(),
      'assignedToActorId': assignedToActorId,
      'sequenceOrder': sequenceOrder,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      name: json['name'] as String,
      status: WorkStepStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      assignedToActorId: json['assignedToActorId'] as String?,
      sequenceOrder: json['sequenceOrder'] as int,
    );
  }

  SubTask copyWith({
    String? id,
    String? taskId,
    String? name,
    WorkStepStatus? status,
    String? assignedToActorId,
    int? sequenceOrder,
  }) {
    return SubTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      status: status ?? this.status,
      assignedToActorId: assignedToActorId ?? this.assignedToActorId,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
    );
  }
}

