import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/workflow_manager_controller.dart';
import '../../../config/constants/app_colors.dart';
import '../../../models/enums.dart';

/// Priority distribution chart
/// Single Responsibility: Display priority distribution
class PriorityDistributionChart extends StatelessWidget {
  final WorkflowManagerController controller;

  const PriorityDistributionChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final allTasks = controller.allTasks;
    int immediate = 0;
    int medium = 0;
    int longTerm = 0;

    for (var task in allTasks) {
      for (var ws in task.workSteps) {
        if (ws.status != WorkStepStatus.completed) {
          final remainingSteps = task.workSteps
              .where((tws) =>
                  tws.sequenceOrder > ws.sequenceOrder &&
                  tws.status != WorkStepStatus.completed)
              .length;
          final priority = ws.getEffectivePriority(task.deadline, remainingSteps);
          switch (priority) {
            case Priority.immediate:
              immediate++;
              break;
            case Priority.medium:
              medium++;
              break;
            case Priority.longTerm:
              longTerm++;
              break;
          }
        }
      }
    }

    final total = immediate + medium + longTerm;

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
                  Icons.priority_high_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Priority Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: total.toDouble() + (total * 0.2),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.primary,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Immediate');
                          case 1:
                            return const Text('Medium');
                          case 2:
                            return const Text('Long Term');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: immediate.toDouble(),
                        color: AppColors.immediatePriority,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: medium.toDouble(),
                        color: AppColors.mediumPriority,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: longTerm.toDouble(),
                        color: AppColors.longTermPriority,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildStats(context, immediate, medium, longTerm),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, int immediate, int medium, int longTerm) {
    return Column(
      children: [
        _buildStatRow(context, 'Immediate', immediate, AppColors.immediatePriority),
        const SizedBox(height: 8),
        _buildStatRow(context, 'Medium', medium, AppColors.mediumPriority),
        const SizedBox(height: 8),
        _buildStatRow(context, 'Long Term', longTerm, AppColors.longTermPriority),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
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
              Icons.bar_chart_outlined,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

