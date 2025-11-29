import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';

/// Description section of task detail dialog
/// Single Responsibility: Display and edit task description
class DescriptionSection extends StatelessWidget {
  final String? description;
  final bool isEditing;
  final ValueChanged<String?> onUpdate;

  const DescriptionSection({
    super.key,
    required this.description,
    required this.isEditing,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined,
                size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        isEditing
            ? TextField(
                controller: TextEditingController(text: description ?? ''),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add a description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                ),
                onChanged: (value) => onUpdate(value.isEmpty ? null : value),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  description ?? 'No description',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: description != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                ),
              ),
      ],
    );
  }
}

