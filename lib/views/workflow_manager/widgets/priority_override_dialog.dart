import 'package:flutter/material.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';

class PriorityOverrideDialog extends StatelessWidget {
  final Priority? currentPriority;
  final Function(Priority) onPrioritySelected;

  const PriorityOverrideDialog({
    super.key,
    this.currentPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Override Priority'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriorityOption(
            context,
            Priority.immediate,
            AppStrings.immediate,
            AppColors.immediatePriority,
            currentPriority == Priority.immediate,
            () {
              onPrioritySelected(Priority.immediate);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          _buildPriorityOption(
            context,
            Priority.medium,
            AppStrings.medium,
            AppColors.mediumPriority,
            currentPriority == Priority.medium,
            () {
              onPrioritySelected(Priority.medium);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          _buildPriorityOption(
            context,
            Priority.longTerm,
            AppStrings.longTerm,
            AppColors.longTermPriority,
            currentPriority == Priority.longTerm,
            () {
              onPrioritySelected(Priority.longTerm);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    Priority priority,
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

