import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/verification_result.dart';

class RiskGauge extends StatefulWidget {
  final double score; // 0.0 to 1.0
  final VerificationStatus status;
  final double size;

  const RiskGauge({
    super.key,
    required this.score,
    required this.status,
    this.size = 180.0,
  });

  @override
  State<RiskGauge> createState() => _RiskGaugeState();
}

class _RiskGaugeState extends State<RiskGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant RiskGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(begin: oldWidget.score, end: widget.score)
          .animate(CurvedAnimation(
              parent: _animController, curve: Curves.easeOutCubic));
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadialGaugePainter(
                  score: _scoreAnimation.value,
                  color: widget.status.color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_scoreAnimation.value * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.19,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.status.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.status.color.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.status.label,
                      style: TextStyle(
                        fontSize: widget.size * 0.065,
                        fontWeight: FontWeight.bold,
                        color: widget.status.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _RadialGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 12.0;

    // Start angle (bottom-left) to end angle (bottom-right) ~ 270 degrees sweep
    const startAngle = 135.0 * (math.pi / 180.0);
    const totalSweep = 270.0 * (math.pi / 180.0);

    // Track Background Arc
    final bgPaint = Paint()
      ..color = AppTheme.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    // Active Value Arc with Shader Gradient
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.4), color],
        stops: const [0.0, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweep = totalSweep * score.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      activePaint,
    );

    // Outer subtle tick ring
    final tickPaint = Paint()
      ..color = AppTheme.border.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius + 10, tickPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
