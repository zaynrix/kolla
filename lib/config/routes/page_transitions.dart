import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Modern page transitions for go_router
class PageTransitions {
  /// Fade transition
  static CustomTransitionPage fade({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide transition
  static CustomTransitionPage slide({
    required Widget child,
    required GoRouterState state,
    String direction = 'right',
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = _getOffset(direction);
        final tween = Tween(begin: offset, end: Offset.zero);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Scale transition
  static CustomTransitionPage scale({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurveTween(curve: Curves.easeOutCubic).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Offset _getOffset(String direction) {
    switch (direction) {
      case 'up':
        return const Offset(0, 1);
      case 'down':
        return const Offset(0, -1);
      case 'left':
        return const Offset(1, 0);
      case 'right':
      default:
        return const Offset(-1, 0);
    }
  }
}

