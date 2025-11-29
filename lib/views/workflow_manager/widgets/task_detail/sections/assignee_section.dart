import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/actor.dart';
import '../../../../../utils/extensions.dart';

/// Assignee section of task detail dialog
/// Single Responsibility: Display and edit task assignee
class AssigneeSection extends StatelessWidget {
  final String? assignedToActorId;
  final List<Actor> availableActors;
  final bool isEditing;
  final ValueChanged<String?> onUpdate;

  const AssigneeSection({
    super.key,
    required this.assignedToActorId,
    required this.availableActors,
    required this.isEditing,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final assignedActor = assignedToActorId != null && availableActors.isNotEmpty
        ? availableActors.firstWhereOrNull((a) => a.id == assignedToActorId)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline,
                size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Assignee',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        isEditing
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButton<String>(
                  value: assignedToActorId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...availableActors.map((actor) {
                      return DropdownMenuItem<String>(
                        value: actor.id,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.primaryGradient,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  actor.name[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(actor.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: onUpdate,
                ),
              )
            : assignedActor != null
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          assignedActor.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Unassigned',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ),
      ],
    );
  }
}

