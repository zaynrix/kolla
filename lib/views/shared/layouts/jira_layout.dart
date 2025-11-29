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
                // Top App Bar - Web optimized
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!showSidebar)
                        _WebIconButton(
                          icon: Icons.menu,
                          onPressed: () {},
                          tooltip: 'Menu',
                        ),
                      if (title != null) ...[
                        const SizedBox(width: 24),
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                        ),
                      ],
                      const Spacer(),
                      if (actions != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Row(
                            children: actions!,
                          ),
                        ),
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

// Web-optimized icon button with proper hit area
class _WebIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _WebIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  State<_WebIconButton> createState() => _WebIconButtonState();
}

class _WebIconButtonState extends State<_WebIconButton> {
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
        message: widget.tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44, // Web accessibility: min 44x44px
              height: 44,
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.hoverBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.onPressed != null
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

