import 'package:flutter/material.dart';
import '../../../config/constants/app_colors.dart';

/// Notification badge widget
/// Single Responsibility: Display a badge with unread notification count
class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.overdue,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.overdue.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

