import 'package:flutter/material.dart';
import '../../../controllers/workflow_manager_controller.dart';
import '../../../config/constants/app_strings.dart';
import '../../../config/constants/app_colors.dart';

/// Modern search and filters bar
/// Single Responsibility: Handle search and filter UI
class SearchAndFiltersBar extends StatelessWidget {
  final WorkflowManagerController controller;

  const SearchAndFiltersBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _ModernSearchField(
                hintText: AppStrings.search,
                onChanged: controller.setSearchQuery,
                initialValue: controller.searchQuery,
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Filter Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ModernFilterChip(
                label: AppStrings.allTasks,
                isSelected: controller.filter == TaskFilter.all,
                onSelected: () => controller.setFilter(TaskFilter.all),
                icon: Icons.list_rounded,
              ),
              _ModernFilterChip(
                label: AppStrings.atRiskTasks,
                isSelected: controller.filter == TaskFilter.atRisk,
                onSelected: () => controller.setFilter(TaskFilter.atRisk),
                icon: Icons.warning_rounded,
                color: AppColors.atRisk,
              ),
              _ModernFilterChip(
                label: AppStrings.overdueTasks,
                isSelected: controller.filter == TaskFilter.overdue,
                onSelected: () => controller.setFilter(TaskFilter.overdue),
                icon: Icons.error_outline_rounded,
                color: AppColors.overdue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Modern Search Field
class _ModernSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final String initialValue;

  const _ModernSearchField({
    required this.hintText,
    this.onChanged,
    this.initialValue = '',
  });

  @override
  State<_ModernSearchField> createState() => _ModernSearchFieldState();
}

class _ModernSearchFieldState extends State<_ModernSearchField> {
  bool _isFocused = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary
                : AppColors.borderLight,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            widget.onChanged?.call(value);
            setState(() {}); // Update UI for clear button
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused
                  ? AppColors.primary
                  : AppColors.textTertiary,
              size: 22,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15,
              ),
        ),
      ),
    );
  }
}

// Modern Filter Chip
class _ModernFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData icon;
  final Color? color;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.icon,
    this.color,
  });

  @override
  State<_ModernFilterChip> createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<_ModernFilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final chipColor = widget.color ?? AppColors.primary;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? chipColor
                : _isHovered
                    ? chipColor.withValues(alpha: 0.1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? chipColor
                  : AppColors.borderLight,
              width: widget.isSelected ? 0 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : _isHovered
                    ? [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : chipColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

