import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/monalisa_colors.dart';

class MAlert {
  const MAlert._();

  static void showError(BuildContext context, String message) {
    _show(
      context,
      title: 'Aviso',
      description: message,
      icon: Icons.error,
      iconColor: MonalisaColors.danger,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      title: 'Aviso',
      description: message,
      icon: Icons.warning_rounded,
      iconColor: MonalisaColors.warning,
    );
  }

  static Future<void> showSuccess(BuildContext context, String message) {
    return _show(
      context,
      title: 'Aviso',
      description: message,
      icon: Icons.check,
      iconColor: MonalisaColors.success,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String description,
    IconData? icon,
    VoidCallback? onView,
  }) {
    _show(
      context,
      title: title,
      description: description,
      icon: icon ?? Icons.notifications_active_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      onView: onView,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onView,
  }) {
    final overlay = Overlay.of(context);
    final completer = Completer<void>();
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _MAlertOverlay(
          title: title,
          description: description,
          icon: icon,
          iconColor: iconColor,
          onView: onView,
          onDismissed: () {
            entry.remove();
            if (!completer.isCompleted) completer.complete();
          },
        );
      },
    );

    overlay.insert(entry);
    return completer.future;
  }
}

class MNotificationCard extends StatelessWidget {
  final Color? iconColor;
  final String title;
  final String description;
  final IconData? icon;
  final VoidCallback? onViewPressed;

  const MNotificationCard({
    super.key,
    this.iconColor = MonalisaColors.secondaryLight,
    required this.title,
    required this.description,
    this.icon,
    this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: MonalisaColors.surfaceSoft.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor?.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    icon ?? Icons.notifications_active_rounded,
                    size: 18,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textStyle.titleSmall?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MonalisaColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.35,
                          color: MonalisaColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onViewPressed != null) ...[
            const Divider(),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onViewPressed,
                child: Text(
                  'Ver',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor ?? MonalisaColors.secondaryLight,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MAlertOverlay extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onView;
  final VoidCallback onDismissed;

  const _MAlertOverlay({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onView,
    required this.onDismissed,
  });

  @override
  State<_MAlertOverlay> createState() => _MAlertOverlayState();
}

class _MAlertOverlayState extends State<_MAlertOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    await _controller.reverse();
    widget.onDismissed();
  }

  void _handleView() {
    widget.onView?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 8;

    return Positioned(
      top: topPadding,
      left: 8,
      right: 8,
      child: IgnorePointer(
        ignoring: false,
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.18),
                  end: Offset.zero,
                ).animate(_animation),
                child: FadeTransition(
                  opacity: _animation,
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: MNotificationCard(
                      title: widget.title,
                      description: widget.description,
                      icon: widget.icon,
                      iconColor: widget.iconColor,
                      onViewPressed: widget.onView == null ? null : _handleView,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
