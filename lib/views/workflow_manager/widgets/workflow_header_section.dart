import 'package:flutter/material.dart';
import '../../../controllers/workflow_manager_controller.dart';
import '../../../config/constants/app_colors.dart';
import '../../../models/enums.dart';

/// Modern header section for workflow manager
/// Single Responsibility: Display workflow overview stats
class WorkflowHeaderSection extends StatelessWidget {
  final WorkflowManagerController controller;

  const WorkflowHeaderSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final allTasks = controller.allTasks;
    final totalTasks = allTasks.length;
    final atRiskTasks = allTasks.where((t) => t.status == TaskStatus.atRisk).length;
    final overdueTasks = allTasks.where((t) => t.status == TaskStatus.overdue).length;
    final onTrackTasks = allTasks.where((t) => t.status == TaskStatus.onTrack).length;
    
    // Calculate total work steps
    final totalWorkSteps = allTasks.fold<int>(
      0,
      (sum, task) => sum + task.workSteps.length,
    );
    
    final completedWorkSteps = allTasks.fold<int>(
      0,
      (sum, task) => sum + task.workSteps.where((ws) => ws.status == WorkStepStatus.completed).length,
    );
    
    final progressPercentage = totalWorkSteps > 0
        ? (completedWorkSteps / totalWorkSteps * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
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
                      'Workflow Manager',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor and manage all tasks across your team',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Tasks',
                  value: totalTasks.toString(),
                  color: AppColors.primary,
                  icon: Icons.task_alt_rounded,
                  subtitle: '$onTrackTasks on track',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'At Risk',
                  value: atRiskTasks.toString(),
                  color: AppColors.atRisk,
                  icon: Icons.warning_rounded,
                  subtitle: 'Needs attention',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Overdue',
                  value: overdueTasks.toString(),
                  color: AppColors.overdue,
                  icon: Icons.error_outline_rounded,
                  subtitle: 'Action required',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Progress',
                  value: '$progressPercentage%',
                  color: AppColors.success,
                  icon: Icons.trending_up_rounded,
                  subtitle: '$completedWorkSteps/$totalWorkSteps steps',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Modern Stat Card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

