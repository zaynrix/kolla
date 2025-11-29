import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/work_step.dart';
import '../../../../../models/enums.dart';

/// Single work step item widget
/// Single Responsibility: Display and interact with a single work step
class WorkStepItem extends StatelessWidget {
  final WorkStep workStep;
  final Function(WorkStepStatus) onStatusChange;

  const WorkStepItem({
    super.key,
    required this.workStep,
    required this.onStatusChange,
  });

  String _getStatusLabel(WorkStepStatus status) {
    switch (status) {
      case WorkStepStatus.pending:
        return 'Pending';
      case WorkStepStatus.inProgress:
        return 'In Progress';
      case WorkStepStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor(WorkStepStatus status) {
    switch (status) {
      case WorkStepStatus.pending:
        return AppColors.textSecondary;
      case WorkStepStatus.inProgress:
        return AppColors.mediumPriority;
      case WorkStepStatus.completed:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workStep.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workStep.role,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${workStep.durationHours}h',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(workStep.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<WorkStepStatus>(
              value: workStep.status,
              underline: const SizedBox(),
              items: WorkStepStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newStatus) {
                if (newStatus != null && newStatus != workStep.status) {
                  onStatusChange(newStatus);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

