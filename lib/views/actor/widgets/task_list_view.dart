import 'package:flutter/material.dart';
import '../../../controllers/actor_controller.dart';
import '../../../config/constants/app_strings.dart';
import '../../../config/constants/app_colors.dart';
import 'task_card.dart';
import 'actor_stats_card.dart';

class TaskListView extends StatelessWidget {
  final ActorController controller;

  const TaskListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final immediate = controller.immediateWorkSteps;
    final medium = controller.mediumWorkSteps;
    final longTerm = controller.longTermWorkSteps;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          ActorStatsCard(controller: controller),
          
          // Priority sections
          if (immediate.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              AppStrings.immediate,
              AppColors.immediatePriority,
              immediate.length,
            ),
            const SizedBox(height: 12),
            ...immediate.map((ws) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: () => controller.completeWorkStep(ws.id),
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (medium.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              AppStrings.medium,
              AppColors.mediumPriority,
              medium.length,
            ),
            const SizedBox(height: 12),
            ...medium.map((ws) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: () => controller.completeWorkStep(ws.id),
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (longTerm.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              AppStrings.longTerm,
              AppColors.longTermPriority,
              longTerm.length,
            ),
            const SizedBox(height: 12),
            ...longTerm.map((ws) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: () => controller.completeWorkStep(ws.id),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color color,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForPriority(title),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  '$count tasks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPriority(String priority) {
    switch (priority) {
      case 'Immediate':
        return Icons.priority_high;
      case 'Medium':
        return Icons.trending_up;
      case 'Long Term':
        return Icons.schedule;
      default:
        return Icons.task;
    }
  }
}

