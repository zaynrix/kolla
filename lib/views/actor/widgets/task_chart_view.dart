import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/actor_controller.dart';
import '../../../config/constants/app_colors.dart';
import '../../../config/constants/app_strings.dart';
import 'actor_stats_card.dart';

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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats card
          ActorStatsCard(controller: controller),
          
          // Chart section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Task Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: total > 0
                      ? PieChart(
                          PieChartData(
                            sections: [
                              if (immediate > 0)
                                PieChartSectionData(
                                  value: immediate.toDouble(),
                                  title: '$immediate',
                                  color: AppColors.immediatePriority,
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (medium > 0)
                                PieChartSectionData(
                                  value: medium.toDouble(),
                                  title: '$medium',
                                  color: AppColors.mediumPriority,
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (longTerm > 0)
                                PieChartSectionData(
                                  value: longTerm.toDouble(),
                                  title: '$longTerm',
                                  color: AppColors.longTermPriority,
                                  radius: 100,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                            sectionsSpace: 3,
                            centerSpaceRadius: 80,
                          ),
                        )
                      : Center(
                          child: Text(
                            'No tasks to display',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                _buildLegend(context),
              ],
            ),
          ),
        ],
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
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          context,
          AppStrings.medium,
          AppColors.mediumPriority,
          controller.mediumWorkSteps.length,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          context,
          AppStrings.longTerm,
          AppColors.longTermPriority,
          controller.longTermWorkSteps.length,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            '$count tasks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

