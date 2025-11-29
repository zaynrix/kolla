import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/subtask.dart';
import '../../../../../models/actor.dart';
import '../../../../../models/enums.dart';
import '../../../../../utils/extensions.dart';

/// Single subtask item widget
/// Single Responsibility: Display and interact with a single subtask
class SubtaskItem extends StatelessWidget {
  final SubTask subTask;
  final List<Actor> availableActors;
  final bool isEditing;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const SubtaskItem({
    super.key,
    required this.subTask,
    required this.availableActors,
    required this.isEditing,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = subTask.status == WorkStepStatus.completed;
    final assignedActor = subTask.assignedToActorId != null &&
            availableActors.isNotEmpty
        ? availableActors.firstWhereOrNull(
            (a) => a.id == subTask.assignedToActorId)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.backgroundLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.borderLight
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: isCompleted ? null : (_) => onComplete(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Text(
              subTask.name,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
                fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
          if (subTask.assignedToActorId != null && assignedActor != null)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  assignedActor.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              color: AppColors.overdue,
            ),
        ],
      ),
    );
  }
}

