import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/task.dart';

/// Header section of task detail dialog
/// Single Responsibility: Display and edit task header
class HeaderSection extends StatelessWidget {
  final Task task;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onClose;

  const HeaderSection({
    super.key,
    required this.task,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextField(
                  controller: TextEditingController(text: task.name),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    // Update will be handled by parent
                  },
                )
              : Text(
                  task.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: Icon(
            isEditing ? Icons.check : Icons.edit_outlined,
            size: 22,
          ),
          onPressed: onToggleEdit,
          tooltip: isEditing ? 'Save' : 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: onClose,
          tooltip: 'Close',
        ),
      ],
    );
  }
}

