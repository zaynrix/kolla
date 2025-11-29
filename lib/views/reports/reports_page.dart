import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/workflow_manager_controller.dart';
import '../../services/interfaces/i_task_service.dart';
import '../../services/interfaces/i_actor_service.dart';
import '../../config/constants/app_colors.dart';
import '../../config/constants/app_strings.dart';
import '../../models/enums.dart';
import '../shared/layouts/jira_layout.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart' as custom;
import 'widgets/report_stat_card.dart';
import 'widgets/task_status_chart.dart';
import 'widgets/priority_distribution_chart.dart';
import 'widgets/actor_performance_widget.dart';
import 'widgets/task_timeline_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkflowManagerController(
        taskService: context.read<ITaskService>(),
        actorService: context.read<IActorService>(),
      ),
      child: Consumer<WorkflowManagerController>(
        builder: (context, controller, _) {
          return JiraLayout(
            title: 'Reports & Analytics',
            actions: [
              _ModernActionButton(
                icon: Icons.download_rounded,
                onPressed: () {
                  // TODO: Export reports
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Export feature coming soon',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                tooltip: 'Export Report',
              ),
              const SizedBox(width: 8),
              _ModernActionButton(
                icon: Icons.refresh_rounded,
                onPressed: controller.refresh,
                tooltip: AppStrings.refresh,
              ),
            ],
            child: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WorkflowManagerController controller,
  ) {
    if (controller.isLoading) {
      return const LoadingWidget(showSkeleton: true);
    }

    if (controller.error != null) {
      return custom.ErrorWidget(
        error: controller.error!,
        onRetry: controller.refresh,
      );
    }

    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Stats
            _buildOverviewStats(controller),
            const SizedBox(height: 32),

            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TaskStatusChart(controller: controller),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: PriorityDistributionChart(controller: controller),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Actor Performance
            ActorPerformanceWidget(controller: controller),
            const SizedBox(height: 32),

            // Task Timeline
            TaskTimelineChart(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(WorkflowManagerController controller) {
    final allTasks = controller.allTasks;
    final totalTasks = allTasks.length;
    final onTrackTasks = allTasks.where((t) => t.status == TaskStatus.onTrack).length;
    final atRiskTasks = allTasks.where((t) => t.status == TaskStatus.atRisk).length;
    final overdueTasks = allTasks.where((t) => t.status == TaskStatus.overdue).length;

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

    return Row(
      children: [
        Expanded(
          child: ReportStatCard(
            title: 'Total Tasks',
            value: totalTasks.toString(),
            icon: Icons.task_alt_rounded,
            color: AppColors.primary,
            subtitle: '$onTrackTasks on track',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'Completion Rate',
            value: '$progressPercentage%',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            subtitle: '$completedWorkSteps/$totalWorkSteps steps',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'At Risk',
            value: atRiskTasks.toString(),
            icon: Icons.warning_rounded,
            color: AppColors.atRisk,
            subtitle: 'Needs attention',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'Overdue',
            value: overdueTasks.toString(),
            icon: Icons.error_outline_rounded,
            color: AppColors.overdue,
            subtitle: 'Action required',
          ),
        ),
      ],
    );
  }
}

// Modern Action Button
class _ModernActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ModernActionButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<_ModernActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.onPressed != null
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

