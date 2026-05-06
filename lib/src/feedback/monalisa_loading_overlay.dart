import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme/monalisa_colors.dart';

class MLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? title;
  final String? description;
  final Color? color;
  final Color? overlayColor;
  final bool blockInteraction;
  final bool showCard;
  final double borderRadius;

  const MLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.title,
    this.description,
    this.color,
    this.overlayColor,
    this.blockInteraction = true,
    this.showCard = true,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final primary = color ?? Theme.of(context).colorScheme.primary;
    final barrierColor =
        overlayColor ?? Colors.white.withValues(alpha: showCard ? 0.72 : 0.58);

    return MouseRegion(
      cursor: isLoading && blockInteraction
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.basic,
      child: Stack(
        children: [
          AbsorbPointer(absorbing: isLoading && blockInteraction, child: child),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isLoading,
              child: AnimatedOpacity(
                opacity: isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: barrierColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: isLoading ? 1 : 0.96,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: _MLoadingContent(
                        title: title,
                        description: description,
                        color: primary,
                        showCard: showCard,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MLoadingContent extends StatelessWidget {
  final String? title;
  final String? description;
  final Color color;
  final bool showCard;

  const _MLoadingContent({
    required this.title,
    required this.description,
    required this.color,
    required this.showCard,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MLoadingSpinner(color: color),
        if (title != null && title!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            title!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: MonalisaColors.text,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MonalisaColors.textMuted,
                  height: 1.32,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );

    if (!showCard) return content;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MonalisaColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

class _MLoadingSpinner extends StatefulWidget {
  final Color color;

  const _MLoadingSpinner({required this.color});

  @override
  State<_MLoadingSpinner> createState() => _MLoadingSpinnerState();
}

class _MLoadingSpinnerState extends State<_MLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * math.pi * 2,
            child: CustomPaint(
              painter: _MLoadingSpinnerPainter(color: widget.color),
            ),
          );
        },
      ),
    );
  }
}

class _MLoadingSpinnerPainter extends CustomPainter {
  final Color color;

  const _MLoadingSpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi * 0.7;
    const segmentCount = 28;
    const segmentOverlap = 0.01;

    void drawGradientArc() {
      final segmentSweep = sweepAngle / segmentCount;

      for (var index = 0; index < segmentCount; index++) {
        final progress = index / (segmentCount - 1);
        final alpha = progress < 0.5
            ? lerpDouble(0.15, 0.55, progress / 0.5)!
            : lerpDouble(0.55, 1, (progress - 0.5) / 0.5)!;
        final paint = Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = index == 0 || index == segmentCount - 1
              ? StrokeCap.round
              : StrokeCap.butt;

        canvas.drawArc(
          rect,
          startAngle + segmentSweep * index,
          segmentSweep + segmentOverlap,
          false,
          paint,
        );
      }
    }

    drawGradientArc();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi);
    canvas.translate(-center.dx, -center.dy);
    drawGradientArc();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MLoadingSpinnerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
