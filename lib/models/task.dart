import 'enums.dart';
import 'work_step.dart';
import 'subtask.dart';

class Task {
  final String id;
  final String name;
  final String? description; // Task description like Trello
  final DateTime deadline;
  final List<WorkStep> workSteps;
  final List<SubTask> subTasks;
  final String? assignedToActorId; // Main task assignee

  const Task({
    required this.id,
    required this.name,
    this.description,
    required this.deadline,
    required this.workSteps,
    this.subTasks = const [],
    this.assignedToActorId,
  });

  // Computed properties
  int get completedStepsCount =>
      workSteps.where((s) => s.status == WorkStepStatus.completed).length;

  int get remainingStepsCount =>
      workSteps.where((s) => s.status != WorkStepStatus.completed).length;

  int get completedSubTasksCount =>
      subTasks.where((s) => s.status == WorkStepStatus.completed).length;

  int get remainingSubTasksCount =>
      subTasks.where((s) => s.status != WorkStepStatus.completed).length;

  double get progressPercentage {
    final totalItems = workSteps.length + subTasks.length;
    if (totalItems == 0) return 0;
    final completedItems = completedStepsCount + completedSubTasksCount;
    return (completedItems / totalItems) * 100;
  }

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
      'description': description,
      'deadline': deadline.toIso8601String(),
      'workSteps': workSteps.map((ws) => ws.toJson()).toList(),
      'subTasks': subTasks.map((st) => st.toJson()).toList(),
      'assignedToActorId': assignedToActorId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      workSteps: (json['workSteps'] as List)
          .map((ws) => WorkStep.fromJson(ws as Map<String, dynamic>))
          .toList(),
      subTasks: json['subTasks'] != null
          ? (json['subTasks'] as List)
              .map((st) => SubTask.fromJson(st as Map<String, dynamic>))
              .toList()
          : [],
      assignedToActorId: json['assignedToActorId'] as String?,
    );
  }

  // CopyWith method
  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? deadline,
    List<WorkStep>? workSteps,
    List<SubTask>? subTasks,
    String? assignedToActorId,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      workSteps: workSteps ?? this.workSteps,
      subTasks: subTasks ?? this.subTasks,
      assignedToActorId: assignedToActorId ?? this.assignedToActorId,
    );
  }
}

