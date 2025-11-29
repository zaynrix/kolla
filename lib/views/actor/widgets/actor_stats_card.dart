import 'package:flutter/material.dart';
import '../../../controllers/actor_controller.dart';
import '../../../config/constants/app_colors.dart';

class ActorStatsCard extends StatelessWidget {
  final ActorController controller;

  const ActorStatsCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final totalTasks = controller.workSteps.length;
    final immediate = controller.immediateWorkSteps.length;
    final medium = controller.mediumWorkSteps.length;
    final longTerm = controller.longTermWorkSteps.length;
    
    // Calculate total hours
    final totalHours = controller.workSteps.fold<int>(
      0,
      (sum, ws) => sum + ws.durationHours,
    );

    // Calculate overdue/urgent tasks
    final urgentTasks = controller.workSteps.where((ws) {
      final task = controller.getTaskForWorkStep(ws);
      final hoursUntilDeadline = task.deadline.difference(DateTime.now()).inHours;
      return hoursUntilDeadline < 24 && hoursUntilDeadline >= 0;
    }).length;

    final overdueTasks = controller.workSteps.where((ws) {
      final task = controller.getTaskForWorkStep(ws);
      final hoursUntilDeadline = task.deadline.difference(DateTime.now()).inHours;
      return hoursUntilDeadline < 0;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
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
                      'My Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalTasks active tasks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.priority_high,
                  label: 'Immediate',
                  value: immediate.toString(),
                  color: AppColors.immediatePriority,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.trending_up,
                  label: 'Medium',
                  value: medium.toString(),
                  color: AppColors.mediumPriority,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.schedule,
                  label: 'Long Term',
                  value: longTerm.toString(),
                  color: AppColors.longTermPriority,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.access_time,
                  label: 'Total Hours',
                  value: '$totalHours h',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.warning,
                  label: 'Urgent',
                  value: urgentTasks.toString(),
                  color: urgentTasks > 0 ? AppColors.warning : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.error_outline,
                  label: 'Overdue',
                  value: overdueTasks.toString(),
                  color: overdueTasks > 0 ? AppColors.overdue : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

