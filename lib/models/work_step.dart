import 'enums.dart';

class WorkStep {
  final String id;
  final String taskId;
  final String name;
  final int durationHours;
  final String role;
  final WorkStepStatus status;
  final String? assignedToActorId;
  final Priority? manualPriority;
  final int sequenceOrder;

  const WorkStep({
    required this.id,
    required this.taskId,
    required this.name,
    required this.durationHours,
    required this.role,
    required this.status,
    this.assignedToActorId,
    this.manualPriority,
    required this.sequenceOrder,
  });

  // Calculate automatic priority
  Priority calculateAutoPriority(DateTime taskDeadline, int remainingStepsAfter) {
    final now = DateTime.now();
    final totalRemainingHours = durationHours + (remainingStepsAfter * 8);
    final hoursUntilDeadline = taskDeadline.difference(now).inHours;
    final remainingTime = hoursUntilDeadline - totalRemainingHours;

    if (remainingTime <= 8) return Priority.immediate;
    if (remainingTime <= 32) return Priority.medium;
    return Priority.longTerm;
  }

  // Get effective priority (manual override or auto)
  Priority getEffectivePriority(DateTime taskDeadline, int remainingStepsAfter) {
    return manualPriority ?? calculateAutoPriority(taskDeadline, remainingStepsAfter);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'name': name,
      'durationHours': durationHours,
      'role': role,
      'status': status.toString(),
      'assignedToActorId': assignedToActorId,
      'manualPriority': manualPriority?.toString(),
      'sequenceOrder': sequenceOrder,
    };
  }

  factory WorkStep.fromJson(Map<String, dynamic> json) {
    return WorkStep(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      name: json['name'] as String,
      durationHours: json['durationHours'] as int,
      role: json['role'] as String,
      status: WorkStepStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      assignedToActorId: json['assignedToActorId'] as String?,
      manualPriority: json['manualPriority'] != null
          ? Priority.values.firstWhere(
              (e) => e.toString() == json['manualPriority'],
            )
          : null,
      sequenceOrder: json['sequenceOrder'] as int,
    );
  }

  WorkStep copyWith({
    String? id,
    String? taskId,
    String? name,
    int? durationHours,
    String? role,
    WorkStepStatus? status,
    String? assignedToActorId,
    Priority? manualPriority,
    int? sequenceOrder,
  }) {
    return WorkStep(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      durationHours: durationHours ?? this.durationHours,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedToActorId: assignedToActorId ?? this.assignedToActorId,
      manualPriority: manualPriority ?? this.manualPriority,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
    );
  }
}

