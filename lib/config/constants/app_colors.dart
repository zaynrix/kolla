import 'package:flutter/material.dart';

class AppColors {
  // Modern vibrant primary colors - Cyan/Blue gradient
  static const Color primary = Color(0xFF06B6D4); // Modern Cyan
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color secondary = Color(0xFF8B5CF6); // Vibrant Purple
  static const Color accent = Color(0xFFFF6B6B); // Modern Coral Red
  static const Color error = Color(0xFFFF4757);
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFFD93D);
  
  // Modern gradient combinations
  static const List<Color> primaryGradient = [
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF51CF66),
    Color(0xFF40C057),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFFFD93D),
    Color(0xFFFFB84D),
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFFF4757),
    Color(0xFFFF6B6B),
  ];
  
  // Priority colors - modern and vibrant
  static const Color immediatePriority = Color(0xFFFF4757); // Modern Red
  static const Color immediatePriorityLight = Color(0xFFFFE5E7);
  static const Color mediumPriority = Color(0xFFFFB84D); // Warm Orange
  static const Color mediumPriorityLight = Color(0xFFFFF4E6);
  static const Color longTermPriority = Color(0xFF51CF66); // Fresh Green
  static const Color longTermPriorityLight = Color(0xFFE6FCE6);
  
  // Status colors - modern palette
  static const Color onTrack = Color(0xFF51CF66);
  static const Color atRisk = Color(0xFFFFB84D);
  static const Color overdue = Color(0xFFFF4757);
  
  // Modern background colors - soft and clean
  static const Color backgroundLight = Color(0xFFFAFBFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Glassmorphism colors
  static const Color glassBackground = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  
  // Text colors - high contrast
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6C7A89);
  static const Color textTertiary = Color(0xFF95A5A6);
  
  // Modern accent colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFE0F2FE);
  
  // Dark mode colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
}

