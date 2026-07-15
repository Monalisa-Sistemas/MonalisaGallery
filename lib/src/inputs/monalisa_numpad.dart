import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/monalisa_colors.dart';

enum MNumPadResult { confirmed, canceled }

enum MNumPadMode { numeric, text }

enum MNumPadPosition { floating, bottom, right }

class MNumPad extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final GlobalKey? targetKey;
  final MNumPadMode initialMode;
  final MNumPadPosition position;
  final bool showPreview;
  final String previewLabel;
  final String emptyPreviewText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onClear;

  const MNumPad({
    super.key,
    required this.controller,
    this.title = 'Teclado numerico',
    this.targetKey,
    this.initialMode = MNumPadMode.numeric,
    this.position = MNumPadPosition.floating,
    this.showPreview = true,
    this.previewLabel = 'Digitando',
    this.emptyPreviewText = 'Nenhum valor informado',
    this.onConfirm,
    this.onCancel,
    this.onClear,
  });

  static Future<MNumPadResult?> show(
    BuildContext context, {
    required TextEditingController controller,
    String title = 'Teclado numerico',
    GlobalKey? targetKey,
    MNumPadMode initialMode = MNumPadMode.numeric,
    MNumPadPosition position = MNumPadPosition.floating,
    bool showPreview = true,
    String previewLabel = 'Digitando',
    String emptyPreviewText = 'Nenhum valor informado',
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
          initialMode: initialMode,
          position: position,
          showPreview: showPreview,
          previewLabel: previewLabel,
          emptyPreviewText: emptyPreviewText,
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
  static const double _numericPanelWidth = 328;
  static const double _textPanelWidth = 640;
  static const double _rightPanelWidth = 360;
  static const double _panelPadding = 16;

  final _panelKey = GlobalKey();
  final _overlayKey = GlobalKey();
  Offset? _offset;
  Size _panelSize = const Size(_numericPanelWidth, 392);
  Rect? _targetRect;
  late MNumPadMode _mode;
  late MNumPadPosition _position;
  late String _previewText;
  bool _keyboardVisible = true;
  bool _draggingHandle = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _position = widget.position;
    _previewText = widget.controller.text;
    widget.controller.addListener(_syncPreview);
  }

  @override
  void didUpdateWidget(covariant MNumPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_syncPreview);
    _previewText = widget.controller.text;
    widget.controller.addListener(_syncPreview);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncPreview);
    super.dispose();
  }

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

  void _syncPreview() {
    if (!mounted || _previewText == widget.controller.text) return;
    setState(() => _previewText = widget.controller.text);
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

    final nextPanelSize = renderBox.size;
    Offset? nextOffset;

    if (_position == MNumPadPosition.floating) {
      final screenSize = MediaQuery.sizeOf(context);
      nextOffset = _offset == null
          ? Offset(
              (screenSize.width - nextPanelSize.width) / 2,
              (screenSize.height - nextPanelSize.height) / 2,
            )
          : _clampOffset(_offset!, screenSize, nextPanelSize);
    }

    final offsetChanged =
        _position == MNumPadPosition.floating && _offset != nextOffset;

    if (_panelSize != nextPanelSize ||
        offsetChanged ||
        _targetRect != nextTargetRect) {
      setState(() {
        _panelSize = nextPanelSize;
        if (_position == MNumPadPosition.floating) _offset = nextOffset;
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

  double _floatingWidth(Size screenSize) {
    final desiredWidth =
        _mode == MNumPadMode.numeric ? _numericPanelWidth : _textPanelWidth;

    return math
        .min(desiredWidth, math.max(260.0, screenSize.width - 24))
        .toDouble();
  }

  double _rightWidth(Size screenSize) {
    if (_mode == MNumPadMode.text) {
      return math
          .min(_textPanelWidth, math.max(280.0, screenSize.width - 32))
          .toDouble();
    }

    return math
        .min(_rightPanelWidth, math.max(280.0, screenSize.width - 32))
        .toDouble();
  }

  MNumPadPosition _effectivePosition(Size screenSize) {
    if (_position == MNumPadPosition.right && screenSize.width < 720) {
      return MNumPadPosition.bottom;
    }

    return _position;
  }

  void _move(DragUpdateDetails details) {
    final screenSize = MediaQuery.sizeOf(context);
    final floatingWidth = _floatingWidth(screenSize);
    final wasDocked = _position != MNumPadPosition.floating;
    final dragPanelSize = wasDocked
        ? Size(floatingWidth, _panelSize.height)
        : _panelSize;
    final currentOffset = wasDocked
        ? Offset(
            (screenSize.width - floatingWidth) / 2,
            screenSize.height - _panelSize.height - _panelPadding,
          )
        : (_offset ?? Offset.zero);
    final nextOffset = currentOffset + details.delta;
    setState(() {
      _position = MNumPadPosition.floating;
      _offset = _clampOffset(nextOffset, screenSize, dragPanelSize);
    });
  }

  void _startMove(DragStartDetails details) {
    _draggingHandle = true;
  }

  void _endMove(DragEndDetails details) {
    _draggingHandle = false;
  }

  void _cancelMove() {
    _draggingHandle = false;
  }

  void _anchorToBottom() {
    if (_draggingHandle || _position == MNumPadPosition.bottom) return;
    setState(() => _position = MNumPadPosition.bottom);
    _scheduleLayoutSync();
  }

  Future<void> _changeMode(MNumPadMode mode) async {
    if (_mode == mode) return;
    setState(() => _keyboardVisible = false);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    setState(() => _mode = mode);
    _scheduleLayoutSync();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() => _keyboardVisible = true);
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

  void _backspace() {
    final currentValue = widget.controller.value;
    final selection = currentValue.selection;
    final text = currentValue.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final normalizedStart = start.clamp(0, text.length).toInt();
    final normalizedEnd = end.clamp(0, text.length).toInt();

    if (normalizedStart != normalizedEnd) {
      final nextText = text.replaceRange(normalizedStart, normalizedEnd, '');
      widget.controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: normalizedStart),
      );
      return;
    }

    if (normalizedStart == 0) return;
    final nextText = text.replaceRange(normalizedStart - 1, normalizedStart, '');
    widget.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: normalizedStart - 1),
    );
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
    final position = _effectivePosition(screenSize);
    final width = switch (position) {
      MNumPadPosition.bottom => screenSize.width,
      MNumPadPosition.right => _rightWidth(screenSize),
      MNumPadPosition.floating => _floatingWidth(screenSize),
    };
    final maxHeight = position == MNumPadPosition.right
        ? math.max(300.0, screenSize.height - (_panelPadding * 2)).toDouble()
        : math.max(300.0, screenSize.height - 24).toDouble();
    final offset = _offset ??
        Offset(
          (screenSize.width - width) / 2,
          math.max(_panelPadding, (screenSize.height - _panelSize.height) / 2),
        );
    final panel = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: maxHeight,
      ),
      child: _NumPadPanel(
        key: _panelKey,
        width: width,
        position: position,
        mode: _mode,
        keyboardVisible: _keyboardVisible,
        showPreview: widget.showPreview,
        previewLabel: widget.previewLabel,
        emptyPreviewText: widget.emptyPreviewText,
        previewText: _previewText,
        title: widget.title,
        onModeChanged: _changeMode,
        onAnchorToBottom: _anchorToBottom,
        onDragStart: _startMove,
        onDragUpdate: _move,
        onDragEnd: _endMove,
        onDragCancel: _cancelMove,
        onDigit: _insert,
        onBackspace: _backspace,
        onCancel: _cancel,
        onConfirm: _confirm,
      ),
    );
    final positionedPanel = switch (position) {
      MNumPadPosition.bottom => Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: panel,
        ),
      MNumPadPosition.right => Positioned(
          right: _panelPadding,
          bottom: _panelPadding,
          child: panel,
        ),
      MNumPadPosition.floating => Positioned(
          left: offset.dx,
          top: offset.dy,
          child: panel,
        ),
    };

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
          positionedPanel,
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
  final MNumPadPosition position;
  final MNumPadMode mode;
  final bool keyboardVisible;
  final bool showPreview;
  final String previewLabel;
  final String emptyPreviewText;
  final String previewText;
  final String title;
  final ValueChanged<MNumPadMode> onModeChanged;
  final VoidCallback onAnchorToBottom;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final GestureDragCancelCallback onDragCancel;

  const _NumPadPanel({
    super.key,
    required this.width,
    required this.position,
    required this.mode,
    required this.keyboardVisible,
    required this.showPreview,
    required this.previewLabel,
    required this.emptyPreviewText,
    required this.previewText,
    required this.title,
    required this.onModeChanged,
    required this.onAnchorToBottom,
    required this.onDigit,
    required this.onBackspace,
    required this.onCancel,
    required this.onConfirm,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBottomPosition = position == MNumPadPosition.bottom;
    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(10),
        bottom: Radius.circular(isBottomPosition ? 0 : 10),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(10),
            bottom: Radius.circular(isBottomPosition ? 0 : 10),
          ),
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
                    onTap: onAnchorToBottom,
                    onPanStart: onDragStart,
                    onPanUpdate: onDragUpdate,
                    onPanEnd: onDragEnd,
                    onPanCancel: onDragCancel,
                    child: Tooltip(
                      message: 'Mover ou fixar teclado embaixo',
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
                            position == MNumPadPosition.bottom
                                ? Icons.keyboard_hide_outlined
                                : Icons.open_with_rounded,
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
                  _NumPadModeSwitch(
                    mode: mode,
                    onChanged: onModeChanged,
                  ),
                ],
              ),
              if (showPreview) ...[
                const SizedBox(height: 10),
                _NumPadPreview(
                  label: previewLabel,
                  value: previewText,
                  emptyText: emptyPreviewText,
                  mode: mode,
                ),
              ],
              const SizedBox(height: 14),
              AnimatedOpacity(
                opacity: keyboardVisible ? 1 : 0,
                duration: const Duration(milliseconds: 40),
                curve: Curves.easeOutCubic,
                child: mode == MNumPadMode.numeric
                    ? _NumericKeyboard(
                        visible: keyboardVisible,
                        onDigit: onDigit,
                        onBackspace: onBackspace,
                      )
                    : _TextKeyboard(
                        visible: keyboardVisible,
                        onInput: onDigit,
                        onBackspace: onBackspace,
                        onCancel: onCancel,
                        onConfirm: onConfirm,
                      ),
              ),
              if (mode == MNumPadMode.numeric) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}

class _NumPadPreview extends StatelessWidget {
  final String label;
  final String value;
  final String emptyText;
  final MNumPadMode mode;

  const _NumPadPreview({
    required this.label,
    required this.value,
    required this.emptyText,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasValue = value.isNotEmpty;
    final alignment =
        mode == MNumPadMode.numeric ? TextAlign.right : TextAlign.left;
    final crossAxisAlignment = mode == MNumPadMode.numeric
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MonalisaColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasValue
              ? primary.withValues(alpha: 0.24)
              : MonalisaColors.border.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: mode == MNumPadMode.numeric
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 13,
                color: MonalisaColors.textMuted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: alignment,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MonalisaColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasValue ? value : emptyText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignment,
            style: theme.textTheme.titleMedium?.copyWith(
              color: hasValue ? MonalisaColors.text : MonalisaColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumPadModeSwitch extends StatelessWidget {
  final MNumPadMode mode;
  final ValueChanged<MNumPadMode> onChanged;

  const _NumPadModeSwitch({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: 78,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: MonalisaColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MonalisaColors.border.withValues(alpha: 0.55)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: mode == MNumPadMode.numeric
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 34,
              height: 26,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: primary.withValues(alpha: 0.26)),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ModeSwitchOption(
                  icon: Icons.dialpad_rounded,
                  tooltip: 'Teclado numerico',
                  selected: mode == MNumPadMode.numeric,
                  onPressed: () => onChanged(MNumPadMode.numeric),
                ),
              ),
              Expanded(
                child: _ModeSwitchOption(
                  icon: Icons.keyboard_alt_outlined,
                  tooltip: 'Teclado completo',
                  selected: mode == MNumPadMode.text,
                  onPressed: () => onChanged(MNumPadMode.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSwitchOption extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  const _ModeSwitchOption({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        overlayColor: WidgetStatePropertyAll(primary.withValues(alpha: 0.06)),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Icon(
              icon,
              key: ValueKey('$tooltip-$selected'),
              size: 17,
              color: selected ? primary : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumericKeyboard extends StatelessWidget {
  final bool visible;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumericKeyboard({
    required this.visible,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NumPadRow(
          children: [
            _KeyboardWaveItem(
              visible: visible,
              index: 0,
              child: _NumPadButton(label: '7', onPressed: () => onDigit('7')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 1,
              child: _NumPadButton(label: '8', onPressed: () => onDigit('8')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 2,
              child: _NumPadButton(label: '9', onPressed: () => onDigit('9')),
            ),
          ],
        ),
        _NumPadRow(
          children: [
            _KeyboardWaveItem(
              visible: visible,
              index: 0,
              child: _NumPadButton(label: '4', onPressed: () => onDigit('4')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 1,
              child: _NumPadButton(label: '5', onPressed: () => onDigit('5')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 2,
              child: _NumPadButton(label: '6', onPressed: () => onDigit('6')),
            ),
          ],
        ),
        _NumPadRow(
          children: [
            _KeyboardWaveItem(
              visible: visible,
              index: 0,
              child: _NumPadButton(label: '1', onPressed: () => onDigit('1')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 1,
              child: _NumPadButton(label: '2', onPressed: () => onDigit('2')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 2,
              child: _NumPadButton(label: '3', onPressed: () => onDigit('3')),
            ),
          ],
        ),
        _NumPadRow(
          children: [
            _KeyboardWaveItem(
              visible: visible,
              index: 0,
              child: _NumPadButton(label: '0', onPressed: () => onDigit('0')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 1,
              child: _NumPadButton(label: ',', onPressed: () => onDigit(',')),
            ),
            _KeyboardWaveItem(
              visible: visible,
              index: 2,
              child: _NumPadButton(
                label: '',
                icon: Icons.backspace_outlined,
                compactText: true,
                foregroundColor: MonalisaColors.textMuted,
                onPressed: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextKeyboard extends StatelessWidget {
  final bool visible;
  final ValueChanged<String> onInput;
  final VoidCallback onBackspace;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _TextKeyboard({
    required this.visible,
    required this.onInput,
    required this.onBackspace,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TextKeyboardNumberRow(
          visible: visible,
          onInput: onInput,
          onBackspace: onBackspace,
        ),
        _TextKeyboardRow(
          visible: visible,
          keys: const ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
          onInput: onInput,
        ),
        _TextKeyboardRow(
          visible: visible,
          keys: const ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
          horizontalPadding: 18,
          onInput: onInput,
        ),
        _TextKeyboardRow(
          visible: visible,
          keys: const ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
          horizontalPadding: 54,
          onInput: onInput,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: _KeyboardWaveItem(
                  visible: visible,
                  index: 0,
                  child: _NumPadButton(
                    label: '',
                    icon: Icons.close_rounded,
                    compactText: true,
                    foregroundColor: MonalisaColors.textMuted,
                    hoverForegroundColor: MonalisaColors.danger,
                    onPressed: onCancel,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: _KeyboardWaveItem(
                  visible: visible,
                  index: 1,
                  child: _NumPadButton(
                    label: 'Espaco',
                    compactText: true,
                    onPressed: () => onInput(' '),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KeyboardWaveItem(
                  visible: visible,
                  index: 2,
                  child: _NumPadButton(
                    label: '',
                    icon: Icons.check_rounded,
                    compactText: true,
                    backgroundColor: MonalisaColors.success,
                    foregroundColor: Colors.white,
                    onPressed: onConfirm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextKeyboardNumberRow extends StatelessWidget {
  final bool visible;
  final ValueChanged<String> onInput;
  final VoidCallback onBackspace;

  const _TextKeyboardNumberRow({
    required this.visible,
    required this.onInput,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (var index = 0; index < keys.length; index++) ...[
            Expanded(
              child: _KeyboardWaveItem(
                visible: visible,
                index: index,
                child: _NumPadButton(
                  label: keys[index],
                  onPressed: () => onInput(keys[index]),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: _KeyboardWaveItem(
              visible: visible,
              index: keys.length,
              child: _NumPadButton(
                label: '',
                icon: Icons.backspace_outlined,
                compactText: true,
                foregroundColor: MonalisaColors.textMuted,
                onPressed: onBackspace,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextKeyboardRow extends StatelessWidget {
  final bool visible;
  final List<String> keys;
  final ValueChanged<String> onInput;
  final double horizontalPadding;

  const _TextKeyboardRow({
    required this.visible,
    required this.keys,
    required this.onInput,
    this.horizontalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 8,
      ),
      child: Row(
        children: [
          for (var index = 0; index < keys.length; index++) ...[
            Expanded(
              child: _KeyboardWaveItem(
                visible: visible,
                index: index,
                child: _NumPadButton(
                  label: keys[index],
                  onPressed: () => onInput(keys[index]),
                ),
              ),
            ),
            if (index < keys.length - 1) const SizedBox(width: 8),
          ],
        ],
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

class _KeyboardWaveItem extends StatefulWidget {
  final bool visible;
  final int index;
  final Widget child;

  const _KeyboardWaveItem({
    required this.visible,
    required this.index,
    required this.child,
  });

  @override
  State<_KeyboardWaveItem> createState() => _KeyboardWaveItemState();
}

class _KeyboardWaveItemState extends State<_KeyboardWaveItem> {
  Timer? _timer;
  late bool _show;

  @override
  void initState() {
    super.initState();
    _show = widget.visible;
    if (widget.visible) _scheduleShow();
  }

  @override
  void didUpdateWidget(covariant _KeyboardWaveItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) return;

    _timer?.cancel();
    if (!widget.visible) {
      setState(() => _show = false);
      return;
    }

    _show = false;
    _scheduleShow();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleShow() {
    final delay = Duration(milliseconds: widget.index * 12);
    _timer = Timer(delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _show ? 1 : 0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _show ? Offset.zero : const Offset(-0.04, 0),
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: widget.child,
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

    final iconOnly = icon != null && label.isEmpty;
    final child = iconOnly
        ? Center(child: Icon(icon, size: 18))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compactText ? 13 : 18,
                    fontWeight: FontWeight.w800,
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
