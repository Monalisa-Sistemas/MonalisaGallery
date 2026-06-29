import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum MButtonVariant { filled, outlined, text }

class MButton extends StatefulWidget {
  final String label;
  final FutureOr<void> Function()? onPressed;
  final IconData? icon;
  final MButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expanded;
  final bool loading;
  final EdgeInsetsGeometry? margin;

  const MButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = MButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.expanded = false,
    this.loading = false,
    this.margin,
  });

  factory MButton.outlined({
    Key? key,
    required String label,
    required FutureOr<void> Function()? onPressed,
    IconData? icon,
    Color? foregroundColor,
    bool expanded = false,
    bool loading = false,
    EdgeInsetsGeometry? margin,
  }) {
    return MButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: MButtonVariant.outlined,
      foregroundColor: foregroundColor,
      expanded: expanded,
      loading: loading,
      margin: margin,
    );
  }

  @override
  State<MButton> createState() => _MButtonState();
}

class _MButtonState extends State<MButton> {
  bool _internalLoading = false;

  bool get _loading => widget.loading || _internalLoading;
  bool get _enabled => widget.onPressed != null && !_loading;

  Future<void> _handlePressed() async {
    final callback = widget.onPressed;
    if (callback == null || _loading) return;

    try {
      final result = callback();
      if (result is Future) {
        setState(() => _internalLoading = true);
        await result;
      }
    } finally {
      if (mounted && _internalLoading) {
        setState(() => _internalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.backgroundColor ?? theme.colorScheme.primary;
    final fg = widget.foregroundColor ??
        (widget.variant == MButtonVariant.filled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary);
    final hoverOverlay = fg.withValues(alpha: 0.10);
    final pressedOverlay = fg.withValues(alpha: 0.16);
    final labelFontWeight = defaultTargetPlatform == TargetPlatform.android
        ? FontWeight.w800
        : FontWeight.w700;

    final child = Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: const Duration(milliseconds: 80),
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: labelFontWeight),
                ),
              ),
            ],
          ),
        ),
        if (_loading)
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
      ],
    );

    final style = ButtonStyle(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      animationDuration: const Duration(milliseconds: 140),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return pressedOverlay;
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return hoverOverlay;
        }
        return null;
      }),
      mouseCursor: WidgetStatePropertyAll(
        _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      ),
    );

    final button = switch (widget.variant) {
      MButtonVariant.filled => ElevatedButton(
          onPressed: _enabled ? _handlePressed : null,
          style: style.copyWith(
            backgroundColor: WidgetStatePropertyAll(bg),
            foregroundColor: WidgetStatePropertyAll(fg),
            elevation: const WidgetStatePropertyAll(0),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
          child: child,
        ),
      MButtonVariant.outlined => OutlinedButton(
          onPressed: _enabled ? _handlePressed : null,
          style: style.copyWith(
            foregroundColor: WidgetStatePropertyAll(fg),
            side: WidgetStatePropertyAll(
              BorderSide(color: fg.withValues(alpha: 0.42)),
            ),
          ),
          child: child,
        ),
      MButtonVariant.text => TextButton(
          onPressed: _enabled ? _handlePressed : null,
          style: style.copyWith(foregroundColor: WidgetStatePropertyAll(fg)),
          child: child,
        ),
    };

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: widget.expanded ? double.infinity : null,
        child: button,
      ),
    );
  }
}

class MToggleButton extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onSelected;
  final String? value;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool enabled;

  const MToggleButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.backgroundColor,
    this.foregroundColor,
    this.enabled = true,
  }) : assert(items.length > 0, 'MToggleButton precisa de pelo menos um item.');

  @override
  State<MToggleButton> createState() => _MToggleButtonState();
}

class _MToggleButtonState extends State<MToggleButton> {
  late String _selectedValue;
  int? _hoveredIndex;

  String get _currentValue =>
      widget.value != null && widget.items.contains(widget.value)
          ? widget.value!
          : _selectedValue;

  int get _selectedIndex {
    final index = widget.items.indexOf(_currentValue);
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value != null && widget.items.contains(widget.value)
        ? widget.value!
        : widget.items.first;
  }

  @override
  void didUpdateWidget(covariant MToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.items.contains(_selectedValue)) {
      _selectedValue = widget.items.first;
    }

    if (widget.value != null && widget.items.contains(widget.value)) {
      _selectedValue = widget.value!;
    }
  }

  void _select(String item) {
    if (!widget.enabled || item == _currentValue) return;
    setState(() => _selectedValue = item);
    widget.onSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBackground = widget.enabled
        ? widget.backgroundColor ?? theme.colorScheme.primary
        : Colors.grey.shade300;
    final selectedForeground = widget.enabled
        ? widget.foregroundColor ?? theme.colorScheme.onPrimary
        : Colors.grey.shade700;
    final unselectedForeground =
        widget.enabled ? Colors.black87 : Colors.grey.shade500;

    return LayoutBuilder(
      builder: (context, constraints) {
        const outerPadding = 4.0;
        const segmentGap = 3.0;
        final availableWidth = constraints.maxWidth - (outerPadding * 2);
        final segmentWidth = availableWidth / widget.items.length;

        return MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          onExit: (_) {
            if (_hoveredIndex != null) setState(() => _hoveredIndex = null);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(outerPadding),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.enabled
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.grey.shade300,
              ),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  left: _selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: segmentGap),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selectedBackground,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var index = 0; index < widget.items.length; index++)
                      Expanded(
                        child: _ToggleButtonItem(
                          label: widget.items[index],
                          selected: index == _selectedIndex,
                          hovered: index == _hoveredIndex,
                          enabled: widget.enabled,
                          selectedForeground: selectedForeground,
                          unselectedForeground: unselectedForeground,
                          onHover: (hovered) {
                            if (!widget.enabled) return;
                            setState(() {
                              _hoveredIndex = hovered ? index : null;
                            });
                          },
                          onTap: () => _select(widget.items[index]),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToggleButtonItem extends StatelessWidget {
  final String label;
  final bool selected;
  final bool hovered;
  final bool enabled;
  final Color selectedForeground;
  final Color unselectedForeground;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _ToggleButtonItem({
    required this.label,
    required this.selected,
    required this.hovered,
    required this.enabled,
    required this.selectedForeground,
    required this.unselectedForeground,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hoverColor =
        selected ? Colors.transparent : Colors.black.withValues(alpha: 0.035);

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: hovered ? hoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            style: TextStyle(
              color: selected ? selectedForeground : unselectedForeground,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              overflow: TextOverflow.ellipsis,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MIconButton extends StatefulWidget {
  final IconData icon;
  final FutureOr<void> Function()? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool loading;

  const MIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 40,
    this.loading = false,
  });

  @override
  State<MIconButton> createState() => _MIconButtonState();
}

class _MIconButtonState extends State<MIconButton> {
  bool _internalLoading = false;

  bool get _loading => widget.loading || _internalLoading;
  bool get _enabled => widget.onPressed != null && !_loading;

  Future<void> _handlePressed() async {
    final callback = widget.onPressed;
    if (callback == null || _loading) return;

    try {
      final result = callback();
      if (result is Future) {
        setState(() => _internalLoading = true);
        await result;
      }
    } finally {
      if (mounted && _internalLoading) {
        setState(() => _internalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor =
        widget.foregroundColor ?? theme.colorScheme.onPrimary;
    final button = IconButton.filled(
      onPressed: _enabled ? _handlePressed : null,
      tooltip: widget.tooltip,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        fixedSize: Size.square(widget.size),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (_loading) return backgroundColor;
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (_loading) return foregroundColor;
          return null;
        }),
        mouseCursor: WidgetStatePropertyAll(
          _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        ),
      ),
      icon: _loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Icon(widget.icon, size: widget.size * 0.48),
    );

    return button;
  }
}

class MActionButton extends StatefulWidget {
  final IconData icon;
  final FutureOr<void> Function()? onPressed;
  final String tooltip;
  final bool danger;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.danger = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<MActionButton> createState() => _MActionButtonState();
}

class _MActionButtonState extends State<MActionButton> {
  bool _internalLoading = false;

  bool get _enabled => widget.onPressed != null && !_internalLoading;

  Future<void> _handlePressed() async {
    final callback = widget.onPressed;
    if (callback == null || _internalLoading) return;

    try {
      final result = callback();
      if (result is Future) {
        setState(() => _internalLoading = true);
        await result;
      }
    } finally {
      if (mounted && _internalLoading) {
        setState(() => _internalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackColor =
        widget.danger ? Colors.red : Theme.of(context).colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? fallbackColor;
    final backgroundColor =
        widget.backgroundColor ?? foregroundColor.withValues(alpha: 0.06);
    final borderColor = foregroundColor.withValues(alpha: 0.28);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: InkWell(
          onTap: _enabled ? _handlePressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
              color: backgroundColor,
            ),
            child: _internalLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  )
                : Icon(widget.icon, size: 20, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
