import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CalorieBudgetRing extends StatefulWidget {
  final int consumedCalories;
  final int calorieBudget;
  final int burnedCalories;
  final double size;

  const CalorieBudgetRing({
    super.key,
    required this.consumedCalories,
    required this.calorieBudget,
    this.burnedCalories = 0,
    this.size = 210,
  });

  @override
  State<CalorieBudgetRing> createState() => _CalorieBudgetRingState();
}

class _CalorieBudgetRingState extends State<CalorieBudgetRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CalorieBudgetRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumedCalories != widget.consumedCalories) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int netTarget = widget.calorieBudget + widget.burnedCalories;
    final int remaining = math.max(0, netTarget - widget.consumedCalories);
    final double targetProgress =
        netTarget > 0 ? (widget.consumedCalories / netTarget).clamp(0.0, 1.0) : 0.0;
    final bool isOverBudget = widget.consumedCalories > netTarget;

    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double currentProgress = targetProgress * _animation.value;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: currentProgress,
                    strokeWidth: 14,
                    trackColor: AppColors.border,
                    progressColor: isOverBudget ? AppColors.danger : AppColors.accent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$remaining',
                      style: AppTypography.display.copyWith(
                        color: isOverBudget ? AppColors.danger : AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOverBudget ? 'CALORIES OVER' : 'CALORIES LEFT',
                      style: AppTypography.xs.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Progress Arc
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
