import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/interfaces/i_actor_service.dart';
import '../config/constants/app_strings.dart';
import '../config/constants/app_colors.dart';
import '../utils/animations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final actorService = context.read<IActorService>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.06),
              AppColors.backgroundLight,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 1200 ? 1200 : screenWidth - 48,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth > 800 ? 64 : 32,
                  vertical: screenWidth > 800 ? 64 : 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero Section - Modern & Professional
                    AppAnimations.fadeIn(
                      duration: const Duration(milliseconds: 600),
                      child: _HeroSection(),
                    ),
                    SizedBox(height: screenWidth > 800 ? 64 : 48),

                    // Quick Access Section
                    FutureBuilder(
                      future: actorService.getAllActors(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final actors = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: AppColors.primaryGradient,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Quick Access',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // Actor Cards Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: screenWidth > 1000
                                    ? 3
                                    : screenWidth > 600
                                        ? 2
                                        : 1,
                                childAspectRatio: 2.8,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: actors.length,
                              itemBuilder: (context, index) {
                                final actor = actors[index];
                                return AppAnimations.slideInFromBottom(
                                  offset: 30.0,
                                  duration: Duration(milliseconds: 400 + (index * 100)),
                                  child: _ModernActorCard(
                                    actor: actor,
                                    onTap: () => context.go('/actor/${actor.id}'),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Dashboard Card
                            AppAnimations.slideInFromBottom(
                              offset: 30.0,
                              duration: const Duration(milliseconds: 700),
                              child: _ModernDashboardCard(
                                onTap: () => context.go('/workflow-manager'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Project Summary Section
class _ProjectSummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About Kolla',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Project Description
          Text(
            'Kolla is a collaborative task management system designed to streamline workflows, enable individual work planning with prioritization, and support real-time progress monitoring. The system manages collaboration between different actors through workflows, ensuring efficient task distribution and completion tracking.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
          ),
          const SizedBox(height: 32),
          
          // Features Grid
          _FeaturesGrid(),
          const SizedBox(height: 32),
          
          // Architecture Section
          _ArchitectureSection(),
        ],
      ),
    );
  }
}

// Features Grid
class _FeaturesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.workflow_rounded,
        'title': 'Workflow Management',
        'description': 'Sequential task workflows with automatic assignment and status tracking',
      },
      {
        'icon': Icons.priority_high_rounded,
        'title': 'Smart Prioritization',
        'description': 'Automatic priority calculation based on deadlines and remaining work steps',
      },
      {
        'icon': Icons.update_rounded,
        'title': 'Real-time Updates',
        'description': 'Stream-based automatic updates without user interaction',
      },
      {
        'icon': Icons.people_rounded,
        'title': 'Team Collaboration',
        'description': 'Role-based access control and individual actor dashboards',
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Analytics & Reports',
        'description': 'Comprehensive reports with charts and performance metrics',
      },
      {
        'icon': Icons.drag_indicator_rounded,
        'title': 'Kanban Board',
        'description': 'Trello-style drag & drop interface for visual task management',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature['title'] as String,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  feature['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Architecture Section
class _ArchitectureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.architecture_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Architecture',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kolla is built using the MVCS (Model-View-Controller-Service) architecture pattern, ensuring strict separation between UI and business logic. This design enables:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 16),
          _ArchitectureFeature(
            icon: Icons.tune_rounded,
            title: 'Modifiability',
            description: 'GUI and application logic are independently changeable',
          ),
          const SizedBox(height: 12),
          _ArchitectureFeature(
            icon: Icons.bug_report_rounded,
            title: 'Testability',
            description: 'Each layer can be tested independently',
          ),
          const SizedBox(height: 12),
          _ArchitectureFeature(
            icon: Icons.phone_android_rounded,
            title: 'Portability',
            description: 'GUI can be swapped for different platforms without affecting logic',
          ),
          const SizedBox(height: 12),
          _ArchitectureFeature(
            icon: Icons.security_rounded,
            title: 'Security',
            description: 'Role-based access control with permission management',
          ),
        ],
      ),
    );
  }
}

class _ArchitectureFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ArchitectureFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Modern Hero Section
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Welcome to Kolla',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            'Collaborative Task Management System',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            'Streamline your workflow, track progress, and collaborate seamlessly with your team',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTertiary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Modern Actor Card
class _ModernActorCard extends StatefulWidget {
  final dynamic actor;
  final VoidCallback onTap;

  const _ModernActorCard({
    required this.actor,
    required this.onTap,
  });

  @override
  State<_ModernActorCard> createState() => _ModernActorCardState();
}

class _ModernActorCardState extends State<_ModernActorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.borderLight,
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isHovered ? 0.08 : 0.04,
                  ),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 8 : 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.actor.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.actor.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.actor.role,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    _isHovered ? 4 : 0,
                    0,
                    0,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: _isHovered
                        ? AppColors.primary
                        : AppColors.textTertiary,
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

// Modern Dashboard Card
class _ModernDashboardCard extends StatefulWidget {
  final VoidCallback onTap;

  const _ModernDashboardCard({required this.onTap});

  @override
  State<_ModernDashboardCard> createState() => _ModernDashboardCardState();
}

class _ModernDashboardCardState extends State<_ModernDashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: _isHovered ? 0.4 : 0.3,
                  ),
                  blurRadius: _isHovered ? 32 : 24,
                  offset: Offset(0, _isHovered ? 16 : 12),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 24),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.workflowManager,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Monitor all tasks and team progress in real-time',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    _isHovered ? 6 : 0,
                    0,
                    0,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 22,
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
