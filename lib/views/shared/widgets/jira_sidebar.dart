import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/constants/app_colors.dart';
import '../../../services/interfaces/i_task_service.dart';
import '../../../services/interfaces/i_actor_service.dart';
import '../../../services/interfaces/i_notification_service.dart';
import '../../actor/widgets/create_task_dialog.dart';
import 'notification_center.dart';
import 'notification_badge.dart';

class JiraSidebar extends StatelessWidget {
  final String currentRoute;

  const JiraSidebar({
    super.key,
    required this.currentRoute,
  });

  void _showNotificationCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: NotificationCenter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Kolla',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/workflow-manager',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/workflow-manager'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.work_outline,
                  activeIcon: Icons.work,
                  label: 'My Board',
                  route: '/actor/actor-1',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/actor/actor-1'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.view_kanban_outlined,
                  activeIcon: Icons.view_kanban,
                  label: 'All Boards',
                  route: '/all-boards',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/all-boards'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Team',
                  route: '/team',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/'),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: 'Reports',
                  route: '/reports',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/reports'),
                ),
                const SizedBox(height: 4),
                _NotificationNavItem(
                  currentRoute: currentRoute,
                  onTap: () {
                    _showNotificationCenter(context);
                  },
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'TEAM MEMBERS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Yahya Abunada',
                  route: '/actor/actor-1',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/actor/actor-1'),
                  isCompact: true,
                  badge: 'Front End',
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Martin Krüger',
                  route: '/actor/actor-2',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/actor/actor-2'),
                  isCompact: true,
                  badge: 'Backend',
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Artem Paliesika',
                  route: '/actor/actor-3',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/actor/actor-3'),
                  isCompact: true,
                  badge: 'Backend',
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Marvin Tank',
                  route: '/actor/actor-4',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/actor/actor-4'),
                  isCompact: true,
                  badge: 'Front End',
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Albert Zacher',
                  route: '/actor/actor-5',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/actor/actor-5'),
                  isCompact: true,
                  badge: 'Backend',
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: const _CreateTaskButton(),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;
  final bool isCompact;
  final String? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
    this.isCompact = false,
    this.badge,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Only mark as active if the exact route matches
    // For actor routes, check exact match to avoid highlighting all actors
    final isActive = widget.currentRoute == widget.route;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 12, vertical: widget.isCompact ? 2 : 0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: widget.isCompact
                    ? 10
                    : 14, // Web-optimized: min 44px height
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.12)
                    : _isHovered
                        ? AppColors.hoverBackground
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isActive ? widget.activeIcon : widget.icon,
                    size: widget.isCompact ? 20 : 24,
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: widget.isCompact ? 14 : 15,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (widget.badge != null && widget.isCompact)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.badge!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Create Task Button in Sidebar Footer
class _CreateTaskButton extends StatefulWidget {
  const _CreateTaskButton();

  @override
  State<_CreateTaskButton> createState() => _CreateTaskButtonState();
}

class _CreateTaskButtonState extends State<_CreateTaskButton> {
  bool _isHovered = false;

  void _showCreateTaskDialog() {
    final actorService = context.read<IActorService>();
    final taskService = context.read<ITaskService>();

    // Get first actor as default (can be improved later)
    actorService.getAllActors().then((actors) {
      if (!context.mounted) return;
      if (actors.isEmpty) return;

      final firstActor = actors.first;
      if (!context.mounted) return;

      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      showDialog(
        context: context,
        builder: (dialogContext) => CreateTaskDialog(
          actorId: firstActor.id,
          actorRole: firstActor.role,
          onCreateTask: (task) async {
            await taskService.createTask(
              task.name,
              task.deadline,
              task.workSteps,
              subTasks: task.subTasks,
              assignedToActorId: task.assignedToActorId,
            );
            if (dialogContext.mounted) {
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Task "${task.name}" created successfully'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showCreateTaskDialog,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: _isHovered
                  ? const LinearGradient(
                      colors: AppColors.primaryGradient,
                    )
                  : null,
              color:
                  _isHovered ? null : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: _isHovered ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Create Task',
                  style: TextStyle(
                    color: _isHovered ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification navigation item with badge
class _NotificationNavItem extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onTap;

  const _NotificationNavItem({
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notificationService = context.watch<INotificationService>();

    return StreamBuilder(
      stream: notificationService.watchNotifications(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.hasData
            ? snapshot.data!.where((n) => !n.isRead).length
            : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _NavItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'Notifications',
              route: '/notifications',
              currentRoute: currentRoute,
              onTap: onTap,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: NotificationBadge(count: unreadCount, size: 18),
              ),
          ],
        );
      },
    );
  }
}
