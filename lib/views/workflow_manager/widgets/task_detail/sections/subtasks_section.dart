import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/subtask.dart';
import '../../../../../models/actor.dart';
import '../../../../../models/enums.dart';
import 'subtask_item.dart';
import 'add_subtask_form.dart';

/// Subtasks section of task detail dialog
/// Single Responsibility: Display and manage subtasks
class SubtasksSection extends StatelessWidget {
  final List<SubTask> subTasks;
  final List<Actor> availableActors;
  final bool isEditing;
  final Function(String, String?) onAdd;
  final Function(String) onComplete;
  final Function(String) onDelete;

  const SubtasksSection({
    super.key,
    required this.subTasks,
    required this.availableActors,
    required this.isEditing,
    required this.onAdd,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist_outlined,
                size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Subtasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${subTasks.where((st) => st.status == WorkStepStatus.completed).length}/${subTasks.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (subTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_task_outlined,
                    size: 20, color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Text(
                  'No subtasks yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          )
        else
          ...subTasks.map((subTask) {
            return SubtaskItem(
              subTask: subTask,
              availableActors: availableActors,
              isEditing: isEditing,
              onComplete: () => onComplete(subTask.id),
              onDelete: () => onDelete(subTask.id),
            );
          }),
        if (isEditing) ...[
          const SizedBox(height: 12),
          AddSubtaskForm(
            availableActors: availableActors,
            onAdd: onAdd,
          ),
        ],
      ],
    );
  }
}

