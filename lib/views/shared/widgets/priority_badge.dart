import 'package:flutter/material.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case Priority.immediate:
        color = AppColors.immediatePriority;
        label = AppStrings.immediate;
        break;
      case Priority.medium:
        color = AppColors.mediumPriority;
        label = AppStrings.medium;
        break;
      case Priority.longTerm:
        color = AppColors.longTermPriority;
        label = AppStrings.longTerm;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

