import 'package:flutter/material.dart';

/// Trello-style search bar
class TrelloSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String initialValue;

  const TrelloSearchBar({
    super.key,
    this.onChanged,
    this.initialValue = '',
  });

  @override
  State<TrelloSearchBar> createState() => _TrelloSearchBarState();
}

class _TrelloSearchBarState extends State<TrelloSearchBar> {
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
        height: 36,
        decoration: BoxDecoration(
          color: _isFocused
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: _isFocused
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            widget.onChanged?.call(value);
            setState(() {});
          },
          style: const TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(
              color: _isFocused
                  ? const Color(0xFF5E6C84)
                  : Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: _isFocused
                  ? const Color(0xFF5E6C84)
                  : Colors.white.withValues(alpha: 0.8),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 18,
                      color: _isFocused
                          ? const Color(0xFF5E6C84)
                          : Colors.white.withValues(alpha: 0.8),
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
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

