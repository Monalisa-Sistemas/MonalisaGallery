import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/monalisa_colors.dart';

enum MNumPadResult { confirmed, canceled }

class MNumPad extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final GlobalKey? targetKey;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onClear;

  const MNumPad({
    super.key,
    required this.controller,
    this.title = 'Teclado numerico',
    this.targetKey,
    this.onConfirm,
    this.onCancel,
    this.onClear,
  });

  static Future<MNumPadResult?> show(
    BuildContext context, {
    required TextEditingController controller,
    String title = 'Teclado numerico',
    GlobalKey? targetKey,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onClear,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<MNumPadResult>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MNumPad(
          controller: controller,
          title: title,
          targetKey: targetKey,
          onConfirm: onConfirm,
          onCancel: onCancel,
          onClear: onClear,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MNumPad> createState() => _MNumPadState();
}

class _MNumPadState extends State<MNumPad> {
  static const double _panelWidth = 328;
  static const double _panelPadding = 16;

  final _panelKey = GlobalKey();
  final _overlayKey = GlobalKey();
  Offset? _offset;
  Size _panelSize = const Size(_panelWidth, 392);
  Rect? _targetRect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleLayoutSync();
  }

  void _scheduleLayoutSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncLayout());
    Future<void>.delayed(
      const Duration(milliseconds: 220),
      () {
        if (mounted) _syncLayout();
      },
    );
  }

  void _syncLayout() {
    if (!mounted) return;
    final renderBox =
        _panelKey.currentContext?.findRenderObject() as RenderBox?;
    final nextTargetRect = _readTargetRect();
    if (renderBox == null || !renderBox.hasSize) {
      if (_targetRect != nextTargetRect) {
        setState(() => _targetRect = nextTargetRect);
      }
      return;
    }

    final screenSize = MediaQuery.sizeOf(context);
    final nextPanelSize = renderBox.size;
    final nextOffset = _offset == null
        ? Offset(
            (screenSize.width - nextPanelSize.width) / 2,
            (screenSize.height - nextPanelSize.height) / 2,
          )
        : _clampOffset(_offset!, screenSize, nextPanelSize);

    if (_panelSize != nextPanelSize ||
        _offset != nextOffset ||
        _targetRect != nextTargetRect) {
      setState(() {
        _panelSize = nextPanelSize;
        _offset = nextOffset;
        _targetRect = nextTargetRect;
      });
    }
  }

  Rect? _readTargetRect() {
    final targetContext = widget.targetKey?.currentContext;
    final targetRenderBox = targetContext?.findRenderObject() as RenderBox?;

    if (targetRenderBox == null ||
        !targetRenderBox.hasSize) {
      return null;
    }

    final topLeft = targetRenderBox.localToGlobal(Offset.zero);

    return topLeft & targetRenderBox.size;
  }

  Offset _clampOffset(Offset offset, Size screenSize, Size panelSize) {
    final maxLeft = math.max(
      _panelPadding,
      screenSize.width - panelSize.width - _panelPadding,
    );
    final maxTop = math.max(
      _panelPadding,
      screenSize.height - panelSize.height - _panelPadding,
    );

    return Offset(
      offset.dx.clamp(_panelPadding, maxLeft).toDouble(),
      offset.dy.clamp(_panelPadding, maxTop).toDouble(),
    );
  }

  void _move(DragUpdateDetails details) {
    final screenSize = MediaQuery.sizeOf(context);
    final nextOffset = (_offset ?? Offset.zero) + details.delta;
    setState(() {
      _offset = _clampOffset(nextOffset, screenSize, _panelSize);
    });
  }

  void _insert(String value) {
    final currentValue = widget.controller.value;
    final selection = currentValue.selection;
    final text = currentValue.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final normalizedStart = start.clamp(0, text.length).toInt();
    final normalizedEnd = end.clamp(0, text.length).toInt();
    final nextText = text.replaceRange(normalizedStart, normalizedEnd, value);
    final nextOffset = normalizedStart + value.length;

    widget.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextOffset),
    );
  }

  void _clear() {
    widget.controller.clear();
    widget.onClear?.call();
  }

  void _cancel() {
    widget.onCancel?.call();
    Navigator.of(context, rootNavigator: true).pop(MNumPadResult.canceled);
  }

  void _confirm() {
    widget.onConfirm?.call();
    Navigator.of(context, rootNavigator: true).pop(MNumPadResult.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final width = math
        .min(_panelWidth, math.max(260.0, screenSize.width - 24))
        .toDouble();
    final maxHeight = math.max(300.0, screenSize.height - 24).toDouble();
    final offset = _offset ??
        Offset(
          (screenSize.width - width) / 2,
          math.max(_panelPadding, (screenSize.height - _panelSize.height) / 2),
        );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        key: _overlayKey,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _cancel,
              child: CustomPaint(
                painter: _NumPadScrimPainter(
                  clearRect: _targetRect?.inflate(5),
                ),
              ),
            ),
          ),
          if (_targetRect != null) _NumPadTargetHighlight(rect: _targetRect!),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: width,
                maxHeight: maxHeight,
              ),
              child: _NumPadPanel(
                key: _panelKey,
                width: width,
                title: widget.title,
                onDragUpdate: _move,
                onDigit: _insert,
                onClear: _clear,
                onCancel: _cancel,
                onConfirm: _confirm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumPadScrimPainter extends CustomPainter {
  final Rect? clearRect;

  const _NumPadScrimPainter({this.clearRect});

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final screenPath = Path()..addRect(Offset.zero & size);

    if (clearRect == null) {
      canvas.drawPath(screenPath, scrimPaint);
      return;
    }

    final clearPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(clearRect!, const Radius.circular(10)),
      );
    final scrimPath = Path.combine(
      PathOperation.difference,
      screenPath,
      clearPath,
    );

    canvas.drawPath(scrimPath, scrimPaint);
  }

  @override
  bool shouldRepaint(covariant _NumPadScrimPainter oldDelegate) {
    return oldDelegate.clearRect != clearRect;
  }
}

class _NumPadTargetHighlight extends StatelessWidget {
  final Rect rect;

  const _NumPadTargetHighlight({required this.rect});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final highlightedRect = rect.inflate(5);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      left: highlightedRect.left,
      top: highlightedRect.top,
      width: highlightedRect.width,
      height: highlightedRect.height,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primary.withValues(alpha: 0.68),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumPadPanel extends StatelessWidget {
  final double width;
  final String title;
  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final GestureDragUpdateCallback onDragUpdate;

  const _NumPadPanel({
    super.key,
    required this.width,
    required this.title,
    required this.onDigit,
    required this.onClear,
    required this.onCancel,
    required this.onConfirm,
    required this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: MonalisaColors.border.withValues(alpha: 0.75),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onPanUpdate: onDragUpdate,
                    child: Tooltip(
                      message: 'Mover teclado',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.move,
                        child: Container(
                          width: 34,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: MonalisaColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  MonalisaColors.border.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Icon(
                            Icons.open_with_rounded,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: MonalisaColors.text,
                      ),
                    ),
                  ),
                  _NumPadIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Cancelar',
                    onPressed: onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _NumPadRow(
                children: [
                  _NumPadButton(label: '7', onPressed: () => onDigit('7')),
                  _NumPadButton(label: '8', onPressed: () => onDigit('8')),
                  _NumPadButton(label: '9', onPressed: () => onDigit('9')),
                ],
              ),
              _NumPadRow(
                children: [
                  _NumPadButton(label: '4', onPressed: () => onDigit('4')),
                  _NumPadButton(label: '5', onPressed: () => onDigit('5')),
                  _NumPadButton(label: '6', onPressed: () => onDigit('6')),
                ],
              ),
              _NumPadRow(
                children: [
                  _NumPadButton(label: '1', onPressed: () => onDigit('1')),
                  _NumPadButton(label: '2', onPressed: () => onDigit('2')),
                  _NumPadButton(label: '3', onPressed: () => onDigit('3')),
                ],
              ),
              _NumPadRow(
                children: [
                  _NumPadButton(label: '0', onPressed: () => onDigit('0')),
                  _NumPadButton(label: ',', onPressed: () => onDigit(',')),
                  _NumPadButton(
                    label: 'Limpar',
                    compactText: true,
                    foregroundColor: MonalisaColors.textMuted,
                    onPressed: onClear,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _NumPadButton(
                      label: 'Cancelar',
                      compactText: true,
                      foregroundColor: MonalisaColors.textMuted,
                      hoverForegroundColor: MonalisaColors.danger,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _NumPadButton(
                      label: 'Confirmar',
                      icon: Icons.check_rounded,
                      compactText: true,
                      backgroundColor: MonalisaColors.success,
                      foregroundColor: Colors.white,
                      onPressed: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumPadRow extends StatelessWidget {
  final List<Widget> children;

  const _NumPadRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            Expanded(child: children[index]),
            if (index < children.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _NumPadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? hoverForegroundColor;
  final bool compactText;
  final IconData? icon;

  const _NumPadButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.compactText = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ?? Colors.white;
    final foregroundColor = this.foregroundColor ?? MonalisaColors.text;
    final primary = Theme.of(context).colorScheme.primary;
    final borderColor = this.backgroundColor == null
        ? MonalisaColors.border.withValues(alpha: 0.48)
        : backgroundColor;
    final hoverOverlay = this.backgroundColor == null
        ? primary.withValues(alpha: 0.045)
        : foregroundColor.withValues(alpha: 0.10);
    final pressedOverlay = this.backgroundColor == null
        ? primary.withValues(alpha: 0.08)
        : foregroundColor.withValues(alpha: 0.16);
    final hoverBorderColor = this.backgroundColor == null
        ? primary.withValues(alpha: 0.55)
        : backgroundColor;
    final foreground = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return hoverForegroundColor ?? foregroundColor;
      }
      return foregroundColor;
    });

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: compactText ? 13 : 18,
                  fontWeight: FontWeight.w800,
                  color: foregroundColor,
                ),
          ),
        ),
      ],
    );

    final style = ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      fixedSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
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
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
    );

    final button = backgroundColor == Colors.white
        ? OutlinedButton(
            onPressed: onPressed,
            style: style.copyWith(
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
              foregroundColor: foreground,
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)) {
                  return BorderSide(color: hoverBorderColor);
                }
                return BorderSide(color: borderColor);
              }),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: style.copyWith(
              backgroundColor: WidgetStatePropertyAll(backgroundColor),
              foregroundColor: foreground,
              elevation: const WidgetStatePropertyAll(0),
              surfaceTintColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
            child: child,
          );

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: button,
    );
  }
}

class _NumPadIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _NumPadIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.square(
          dimension: 32,
          child: Icon(icon, size: 19, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
