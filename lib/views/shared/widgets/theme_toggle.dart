import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        // This would need a theme controller to toggle
        // For now, it's a placeholder for future implementation
      },
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
    );
  }
}

