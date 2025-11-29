import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/workflow_manager_controller.dart';
import '../../../config/constants/app_colors.dart';
import '../../../models/enums.dart';

/// Task status distribution chart
/// Single Responsibility: Display task status distribution
class TaskStatusChart extends StatelessWidget {
  final WorkflowManagerController controller;

  const TaskStatusChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final allTasks = controller.allTasks;
    final onTrack = allTasks.where((t) => t.status == TaskStatus.onTrack).length;
    final atRisk = allTasks.where((t) => t.status == TaskStatus.atRisk).length;
    final overdue = allTasks.where((t) => t.status == TaskStatus.overdue).length;
    final total = onTrack + atRisk + overdue;

    if (total == 0) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Task Status Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: [
                  if (onTrack > 0)
                    PieChartSectionData(
                      value: onTrack.toDouble(),
                      title: '$onTrack',
                      color: AppColors.onTrack,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  if (atRisk > 0)
                    PieChartSectionData(
                      value: atRisk.toDouble(),
                      title: '$atRisk',
                      color: AppColors.atRisk,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  if (overdue > 0)
                    PieChartSectionData(
                      value: overdue.toDouble(),
                      title: '$overdue',
                      color: AppColors.overdue,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                ],
                sectionsSpace: 4,
                centerSpaceRadius: 80,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(context, onTrack, atRisk, overdue),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, int onTrack, int atRisk, int overdue) {
    return Column(
      children: [
        _buildLegendItem(context, 'On Track', AppColors.onTrack, onTrack),
        const SizedBox(height: 12),
        _buildLegendItem(context, 'At Risk', AppColors.atRisk, atRisk),
        const SizedBox(height: 12),
        _buildLegendItem(context, 'Overdue', AppColors.overdue, overdue),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                  fontSize: 16,
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count tasks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

