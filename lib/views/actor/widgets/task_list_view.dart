import 'package:flutter/material.dart';
import '../../../controllers/actor_controller.dart';
import '../../../config/constants/app_strings.dart';
import '../../../config/constants/app_colors.dart';
import '../../../utils/animations.dart';
import 'task_card.dart';
import 'priority_section_header.dart';

/// Modern task list view with priority grouping
/// Single Responsibility: Display tasks grouped by priority
class TaskListView extends StatelessWidget {
  final ActorController controller;

  const TaskListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Show all work steps (including completed) like Jira/Trello
    final completed = controller.completedWorkSteps;
    final immediate = controller.immediateWorkSteps;
    final medium = controller.mediumWorkSteps;
    final longTerm = controller.longTermWorkSteps;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immediate Priority Section
          if (immediate.isNotEmpty) ...[
            PrioritySectionHeader(
              title: AppStrings.immediate,
              color: AppColors.immediatePriority,
              count: immediate.length,
              icon: Icons.priority_high_rounded,
            ),
            const SizedBox(height: 16),
            ...immediate.asMap().entries.map((entry) {
              final index = entry.key;
              final ws = entry.value;
              return AppAnimations.slideInFromBottom(
                offset: 30.0,
                duration: Duration(milliseconds: 300 + (index * 50)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: () => controller.completeWorkStep(ws.id),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
          ],

          // Medium Priority Section
          if (medium.isNotEmpty) ...[
            PrioritySectionHeader(
              title: AppStrings.medium,
              color: AppColors.mediumPriority,
              count: medium.length,
              icon: Icons.trending_up_rounded,
            ),
            const SizedBox(height: 16),
            ...medium.map((ws) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: () => controller.completeWorkStep(ws.id),
                  ),
                )),
            const SizedBox(height: 32),
          ],

          // Long Term Priority Section
          if (longTerm.isNotEmpty) ...[
            PrioritySectionHeader(
              title: AppStrings.longTerm,
              color: AppColors.longTermPriority,
              count: longTerm.length,
              icon: Icons.schedule_rounded,
            ),
            const SizedBox(height: 16),
            ...longTerm.map((ws) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: () => controller.completeWorkStep(ws.id),
                  ),
                )),
            const SizedBox(height: 32),
          ],

          // Completed Section (like Jira/Trello)
          if (completed.isNotEmpty) ...[
            PrioritySectionHeader(
              title: 'Completed',
              color: AppColors.success,
              count: completed.length,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 16),
            ...completed.map((ws) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    workStep: ws,
                    task: controller.getTaskForWorkStep(ws),
                    onComplete: null, // No complete button for completed items
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}
