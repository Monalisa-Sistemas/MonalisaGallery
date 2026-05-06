import 'package:flutter/material.dart';

import '../feedback/monalisa_confirm_dialog.dart';

class MCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? description;
  final bool enabled;
  final Color? activeColor;
  final Color? foregroundColor;

  const MCheck({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.description,
    this.enabled = true,
    this.activeColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = activeColor ?? theme.colorScheme.primary;
    final textColor = enabled
        ? foregroundColor ?? Colors.grey.shade900
        : Colors.grey.shade500;
    final descriptionColor =
        enabled ? Colors.grey.shade600 : Colors.grey.shade400;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: InkWell(
        onTap: enabled ? () => onChanged?.call(!value) : null,
        borderRadius: BorderRadius.circular(8),
        hoverColor: primary.withValues(alpha: enabled ? 0.05 : 0),
        splashColor: primary.withValues(alpha: enabled ? 0.08 : 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: value
                      ? primary
                      : enabled
                          ? Colors.white
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value
                        ? primary
                        : enabled
                            ? Colors.grey.shade400
                            : Colors.grey.shade300,
                    width: 1.3,
                  ),
                ),
                child: AnimatedScale(
                  scale: value ? 1 : 0.65,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  child: Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: value ? Colors.white : Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: descriptionColor,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MSwitchToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? description;
  final bool enabled;
  final Color? activeColor;
  final Color? foregroundColor;

  const MSwitchToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.description,
    this.enabled = true,
    this.activeColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = activeColor ?? theme.colorScheme.primary;
    final textColor = enabled
        ? foregroundColor ?? Colors.grey.shade900
        : Colors.grey.shade500;
    final descriptionColor =
        enabled ? Colors.grey.shade600 : Colors.grey.shade400;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: InkWell(
        onTap: enabled ? () => onChanged?.call(!value) : null,
        borderRadius: BorderRadius.circular(8),
        hoverColor: primary.withValues(alpha: enabled ? 0.05 : 0),
        splashColor: primary.withValues(alpha: enabled ? 0.08 : 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: descriptionColor,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 46,
                height: 26,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: value
                      ? primary
                      : enabled
                          ? Colors.grey.shade300
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: enabled ? Colors.white : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MStatusToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String activeLabel;
  final String inactiveLabel;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final Color inactiveColor;
  final String? confirmTitle;
  final String? confirmMessage;
  final String confirmText;
  final String cancelText;
  final bool enabled;
  final double height;
  final bool confirmOnActivate;
  final bool confirmOnDeactivate;

  const MStatusToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.activeIcon,
    required this.inactiveIcon,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.blueGrey,
    this.confirmTitle,
    this.confirmMessage,
    this.confirmText = 'Sim',
    this.cancelText = 'Não',
    this.enabled = true,
    this.height = 45,
    this.confirmOnActivate = false,
    this.confirmOnDeactivate = true,
  });

  @override
  State<MStatusToggle> createState() => _MStatusToggleState();
}

class _MStatusToggleState extends State<MStatusToggle> {
  late bool _value;
  bool _hovered = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant MStatusToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  Future<void> _toggle() async {
    if (!widget.enabled || _busy) return;

    final nextValue = !_value;
    final shouldConfirm = widget.confirmTitle != null &&
        widget.confirmMessage != null &&
        ((nextValue && widget.confirmOnActivate) ||
            (!nextValue && widget.confirmOnDeactivate));

    if (shouldConfirm) {
      setState(() => _busy = true);
      final confirm = await MConfirmDialog.show(
        context,
        title: widget.confirmTitle!,
        description: widget.confirmMessage!,
        confirmText: widget.confirmText,
        cancelText: widget.cancelText,
        confirmColor: nextValue ? widget.activeColor : widget.inactiveColor,
        icon: nextValue ? widget.activeIcon : widget.inactiveIcon,
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (!confirm) return;
    }

    setState(() => _value = nextValue);
    widget.onChanged(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final active = _value;
    final baseColor = active ? widget.activeColor : widget.inactiveColor;
    final backgroundColor = widget.enabled
        ? Color.lerp(baseColor, Colors.white, _hovered && !_busy ? 0.08 : 0)!
        : Colors.grey.shade300;
    final foregroundColor = widget.enabled ? Colors.white : Colors.grey.shade600;
    final label = active ? widget.activeLabel : widget.inactiveLabel;
    final icon = active ? widget.activeIcon : widget.inactiveIcon;

    return MouseRegion(
      cursor: widget.enabled && !_busy
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: widget.height,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (widget.enabled)
                BoxShadow(
                  color: baseColor.withValues(alpha: _hovered ? 0.28 : 0.20),
                  blurRadius: _hovered ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 190),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0, 0.18),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: offset, child: child),
                        );
                      },
                      child: Icon(
                        icon,
                        key: ValueKey(icon),
                        color: foregroundColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 190),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: offset, child: child),
                          );
                        },
                        child: Text(
                          label,
                          key: ValueKey(label),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foregroundColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IgnorePointer(
                child: Switch.adaptive(
                  value: active,
                  onChanged: widget.enabled && !_busy ? (_) {} : null,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.42),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.32),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
