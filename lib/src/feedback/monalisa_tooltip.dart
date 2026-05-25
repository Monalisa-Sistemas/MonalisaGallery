import 'dart:async';

import 'package:flutter/material.dart';

class MToolTip extends StatefulWidget {
  final String title;
  final String description;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double width;

  const MToolTip({
    super.key,
    required this.title,
    required this.description,
    this.backgroundColor,
    this.foregroundColor,
    this.width = 300,
  });

  @override
  State<MToolTip> createState() => _MToolTipState();
}

class _MToolTipState extends State<MToolTip>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool get _isVisible => _overlayEntry != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _scheduleHide() {
    _cancelHide();
    _hideTimer = Timer(const Duration(milliseconds: 90), _hide);
  }

  void _toggle() {
    if (_isVisible) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    _cancelHide();
    if (_isVisible) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.topCenter,
                  followerAnchor: Alignment.bottomCenter,
                  offset: const Offset(0, -10),
                  child: MouseRegion(
                    onEnter: (_) => _cancelHide(),
                    onExit: (_) => _scheduleHide(),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1).animate(
                          _animation,
                        ),
                        alignment: Alignment.bottomCenter,
                        child: _ToolTipBubble(
                          title: widget.title,
                          description: widget.description,
                          width: widget.width,
                          backgroundColor:
                              widget.backgroundColor ?? Colors.white,
                          foregroundColor:
                              widget.foregroundColor ?? Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(from: 0);
  }

  Future<void> _hide() async {
    _cancelHide();
    if (!_isVisible) return;

    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.blueGrey;

    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _show(),
        onExit: (_) => _scheduleHide(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.65)),
              color: Colors.white,
            ),
            child: Icon(
              //Icons.store,
              Icons.question_mark_rounded,
              size: 14,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolTipBubble extends StatelessWidget {
  final String title;
  final String description;
  final double width;
  final Color backgroundColor;
  final Color foregroundColor;

  const _ToolTipBubble({
    required this.title,
    required this.description,
    required this.width,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: foregroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  color: foregroundColor.withValues(alpha: 0.78),
                  fontSize: 12,
                  height: 1.32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
