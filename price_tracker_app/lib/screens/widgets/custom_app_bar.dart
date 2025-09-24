import 'package:flutter/material.dart';

/// Modern top bar with centered title and a rounded search box under it.
/// Matches the screenshot: red header, "Home" centered, white pill search row
/// with [menu] - [placeholder] - [search] - [bell] icons.
class ModernSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ModernSearchAppBar({
    super.key,
    this.title = 'Home',
    this.hintText = 'Search',
    this.onMenuPressed,
    this.onSearchPressed,
    this.onBellPressed,
    this.onChanged,
    this.onSubmitted,
    this.initialQuery,
    this.background,
    this.searchBackground,
    this.titleStyle,
    this.elevation = 0,
  });

  final String title;
  final String hintText;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBellPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? initialQuery;

  /// Optional custom colors
  final Color? background;       // header background (defaults to Theme.primary)
  final Color? searchBackground; // pill bg (defaults to theme card color)
  final TextStyle? titleStyle;

  final double elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = background ?? theme.colorScheme.primary;
    final pillBg = searchBackground ?? theme.colorScheme.surface;
    final titleTextStyle = titleStyle ??
        theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );

    // Slight gradient for a modern feel
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        bg,
        Color.alphaBlend(Colors.white.withOpacity(0.05), bg),
      ],
    );

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row (centered)
              SizedBox(
                height: kToolbarHeight,
                child: Center(
                  child: Text(title, style: titleTextStyle),
                ),
              ),

              // Search pill
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _SearchPill(
                  hintText: hintText,
                  onMenuPressed: onMenuPressed,
                  onSearchPressed: onSearchPressed,
                  onBellPressed: onBellPressed,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  initialQuery: initialQuery,
                  background: pillBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPill extends StatefulWidget {
  const _SearchPill({
    required this.hintText,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onBellPressed,
    this.onChanged,
    this.onSubmitted,
    this.initialQuery,
    this.background,
  });

  final String hintText;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBellPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? initialQuery;
  final Color? background;

  @override
  State<_SearchPill> createState() => _SearchPillState();
}

class _SearchPillState extends State<_SearchPill> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery ?? '');

  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.background ?? theme.cardColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: _focused ? 14 : 10,
            spreadRadius: 0,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(_focused ? 0.12 : 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.onMenuPressed,
            tooltip: 'Menu',
          ),

          // Text field (borderless)
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focused = f),
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                ),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.search),
            onPressed: widget.onSearchPressed ??
                () => widget.onSubmitted?.call(_controller.text),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: widget.onBellPressed,
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}
