import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subtask.dart';
import '../../../models/task.dart';
import '../../../models/enums.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_task_service.dart';
import '../../../utils/extensions.dart';

/// Subtask card for actor page
/// Single Responsibility: Display a single subtask assigned to the actor
class SubtaskCard extends StatefulWidget {
  final SubTask subTask;
  final Task parentTask;

  const SubtaskCard({
    super.key,
    required this.subTask,
    required this.parentTask,
  });

  @override
  State<SubtaskCard> createState() => _SubtaskCardState();
}

class _SubtaskCardState extends State<SubtaskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.subTask.status == WorkStepStatus.completed;
    final hoursUntilDeadline = widget.parentTask.deadline.difference(DateTime.now()).inHours;
    final isUrgent = hoursUntilDeadline < 24 && hoursUntilDeadline >= 0;
    final isOverdue = hoursUntilDeadline < 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        child: Transform.scale(
          scale: _isHovered ? 1.01 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.borderLight,
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isHovered ? 0.1 : 0.05,
                  ),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 6 : 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Open subtask detail dialog
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subtask indicator
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.subdirectory_arrow_right,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subTask.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                        color: isCompleted
                                            ? AppColors.textTertiary
                                            : AppColors.textPrimary,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'From: ${widget.parentTask.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isCompleted
                                            ? AppColors.textTertiary
                                            : AppColors.textSecondary,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.overdue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.overdue, width: 1),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: AppColors.overdue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.warning, width: 1),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Meta Information
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetaChip(
                            icon: Icons.access_time_rounded,
                            label: 'Deadline: ${_formatDeadline(widget.parentTask.deadline)}',
                            color: AppColors.textSecondary,
                          ),
                          if (isCompleted)
                            const _MetaChip(
                              icon: Icons.check_circle_rounded,
                              label: 'COMPLETED',
                              color: AppColors.success,
                              isUrgent: true,
                            ),
                        ],
                      ),

                      // Complete Button
                      if (!isCompleted) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await context.read<ITaskService>().completeSubTask(widget.subTask.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Subtask completed!',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      margin: EdgeInsets.all(16),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.overdue,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 20),
                            label: const Text(
                              'Complete Subtask',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Overdue';
    }
  }
}

// Modern Meta Chip
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isUrgent;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

