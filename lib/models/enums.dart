enum Priority {
  immediate,
  medium,
  longTerm,
}

enum WorkStepStatus {
  pending,
  inProgress,
  completed,
}

enum TaskStatus {
  onTrack,
  atRisk,
  overdue,
}

enum NotificationType {
  workStepCompleted,
  workStepStatusChanged,
  priorityChanged,
  taskAssigned,
  deadlineApproaching,
  taskOverdue,
}

