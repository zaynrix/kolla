import 'package:flutter/material.dart';
import '../../../controllers/workflow_manager_controller.dart';
import '../../../config/constants/app_colors.dart';
import '../../../models/enums.dart';

/// Actor performance widget
/// Single Responsibility: Display actor performance metrics
class ActorPerformanceWidget extends StatelessWidget {
  final WorkflowManagerController controller;

  const ActorPerformanceWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final actors = controller.allActors;
    final allTasks = controller.allTasks;

    if (actors.isEmpty || allTasks.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate performance for each actor
    final performanceData = actors.map((actor) {
      final workSteps = controller.getActorWorkSteps(actor.id);
      final completed = workSteps.where((ws) => ws.status == WorkStepStatus.completed).length;
      final total = workSteps.length;
      final completionRate = total > 0 ? (completed / total * 100).round() : 0;
      
      return _ActorPerformanceData(
        actor: actor,
        totalTasks: workSteps.length,
        completedTasks: completed,
        completionRate: completionRate,
      );
    }).toList();

    performanceData.sort((a, b) => b.completionRate.compareTo(a.completionRate));

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
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Team Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...performanceData.map((data) => _buildActorRow(context, data)),
        ],
      ),
    );
  }

  Widget _buildActorRow(BuildContext context, _ActorPerformanceData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.actor.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Actor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.actor.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.actor.role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.completionRate}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _getCompletionColor(data.completionRate),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data.completedTasks}/${data.totalTasks} tasks',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          
          // Progress Bar
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: data.completionRate / 100,
                minHeight: 8,
                backgroundColor: AppColors.backgroundLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCompletionColor(data.completionRate),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 50) return AppColors.mediumPriority;
    return AppColors.overdue;
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
              Icons.people_outline,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No team data available',
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

class _ActorPerformanceData {
  final dynamic actor;
  final int totalTasks;
  final int completedTasks;
  final int completionRate;

  _ActorPerformanceData({
    required this.actor,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
  });
}

