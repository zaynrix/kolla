import 'enums.dart';
import 'work_step.dart';

class Task {
  final String id;
  final String name;
  final DateTime deadline;
  final List<WorkStep> workSteps;

  const Task({
    required this.id,
    required this.name,
    required this.deadline,
    required this.workSteps,
  });

  // Computed properties
  int get completedStepsCount =>
      workSteps.where((s) => s.status == WorkStepStatus.completed).length;

  int get remainingStepsCount =>
      workSteps.where((s) => s.status != WorkStepStatus.completed).length;

  double get progressPercentage =>
      workSteps.isEmpty ? 0 : (completedStepsCount / workSteps.length) * 100;

  TaskStatus get status {
    final now = DateTime.now();
    final hoursUntilDeadline = deadline.difference(now).inHours;

    if (hoursUntilDeadline < 0) return TaskStatus.overdue;
    if (hoursUntilDeadline < 24 && remainingStepsCount > 2) {
      return TaskStatus.atRisk;
    }
    return TaskStatus.onTrack;
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deadline': deadline.toIso8601String(),
      'workSteps': workSteps.map((ws) => ws.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      workSteps: (json['workSteps'] as List)
          .map((ws) => WorkStep.fromJson(ws as Map<String, dynamic>))
          .toList(),
    );
  }

  // CopyWith method
  Task copyWith({
    String? id,
    String? name,
    DateTime? deadline,
    List<WorkStep>? workSteps,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      deadline: deadline ?? this.deadline,
      workSteps: workSteps ?? this.workSteps,
    );
  }
}

