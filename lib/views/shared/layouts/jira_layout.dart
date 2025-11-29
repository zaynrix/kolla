import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/jira_sidebar.dart';
import '../../../config/constants/app_colors.dart';

class JiraLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showSidebar;

  const JiraLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showSidebar = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          if (showSidebar) JiraSidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!showSidebar)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {},
                        ),
                      if (title != null) ...[
                        const SizedBox(width: 16),
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                        ),
                      ],
                      const Spacer(),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

