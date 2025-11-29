import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/work_step.dart';
import '../../../../../models/enums.dart';
import 'work_step_item.dart';

/// Work steps section of task detail dialog
/// Single Responsibility: Display work steps
class WorkStepsSection extends StatelessWidget {
  final List<WorkStep> workSteps;
  final Function(String, WorkStepStatus) onStatusChange;

  const WorkStepsSection({
    super.key,
    required this.workSteps,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_outlined,
                size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Work Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (workSteps.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              'No work steps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          )
        else
          ...workSteps.map((workStep) {
            return WorkStepItem(
              workStep: workStep,
              onStatusChange: (newStatus) =>
                  onStatusChange(workStep.id, newStatus),
            );
          }),
      ],
    );
  }
}

