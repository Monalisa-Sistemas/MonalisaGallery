import 'package:flutter/material.dart';

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
