import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/actor_controller.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';

/// Modern chart view for task distribution
/// Single Responsibility: Display task distribution chart
class TaskChartView extends StatelessWidget {
  final ActorController controller;

  const TaskChartView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final immediate = controller.immediateWorkSteps.length;
    final medium = controller.mediumWorkSteps.length;
    final longTerm = controller.longTermWorkSteps.length;
    final total = immediate + medium + longTerm;

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks to display',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pie_chart_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Distribution',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Overview of your task priorities',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          if (immediate > 0)
                            PieChartSectionData(
                              value: immediate.toDouble(),
                              title: '$immediate',
                              color: AppColors.immediatePriority,
                              radius: 120,
                              titleStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          if (medium > 0)
                            PieChartSectionData(
                              value: medium.toDouble(),
                              title: '$medium',
                              color: AppColors.mediumPriority,
                              radius: 120,
                              titleStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          if (longTerm > 0)
                            PieChartSectionData(
                              value: longTerm.toDouble(),
                              title: '$longTerm',
                              color: AppColors.longTermPriority,
                              radius: 120,
                              titleStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildLegend(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      children: [
        _buildLegendItem(
          context,
          AppStrings.immediate,
          AppColors.immediatePriority,
          controller.immediateWorkSteps.length,
          Icons.priority_high_rounded,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          context,
          AppStrings.medium,
          AppColors.mediumPriority,
          controller.mediumWorkSteps.length,
          Icons.trending_up_rounded,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          context,
          AppStrings.longTerm,
          AppColors.longTermPriority,
          controller.longTermWorkSteps.length,
          Icons.schedule_rounded,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'task' : 'tasks'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: color,
            size: 24,
          ),
        ],
      ),
    );
  }
}
