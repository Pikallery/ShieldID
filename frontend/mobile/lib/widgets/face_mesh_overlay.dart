import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/theme.dart';

class FaceMeshOverlay extends StatefulWidget {
  final String challengePrompt;
  final double progress; // 0.0 to 1.0
  final bool isFaceDetected;

  const FaceMeshOverlay({
    super.key,
    required this.challengePrompt,
    this.progress = 0.0,
    this.isFaceDetected = true,
  });

  @override
  State<FaceMeshOverlay> createState() => _FaceMeshOverlayState();
}

class _FaceMeshOverlayState extends State<FaceMeshOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ovalWidth = constraints.maxWidth * 0.72;
        final ovalHeight = ovalWidth * 1.35;

        return Stack(
          children: [
            // Darkened cutout with oval mask
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _FaceCutoutPainter(
                ovalWidth: ovalWidth,
                ovalHeight: ovalHeight,
                isDetected: widget.isFaceDetected,
                progress: widget.progress,
              ),
            ),

            // Animated Biometric Landmark Mesh Overlay
            Center(
              child: SizedBox(
                width: ovalWidth,
                height: ovalHeight,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _BiometricMeshPainter(
                        pulse: _pulseController.value,
                        isDetected: widget.isFaceDetected,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Top Challenge Prompt Pill
            Positioned(
              top: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.isFaceDetected
                          ? AppTheme.primaryCyan.withOpacity(0.15)
                          : AppTheme.reviewAmber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: widget.isFaceDetected
                            ? AppTheme.primaryCyan
                            : AppTheme.reviewAmber,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isFaceDetected
                                  ? AppTheme.primaryCyan
                                  : AppTheme.reviewAmber)
                              .withOpacity(0.25),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isFaceDetected
                              ? Icons.face_retouching_natural_rounded
                              : Icons.warning_amber_rounded,
                          color: widget.isFaceDetected
                              ? AppTheme.primaryCyan
                              : AppTheme.reviewAmber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.challengePrompt,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Position your face inside the oval and hold still',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Circular Progress Ring
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: widget.progress,
                        strokeWidth: 4,
                        backgroundColor: AppTheme.surfaceElevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryCyan,
                        ),
                      ),
                      Text(
                        '${(widget.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FaceCutoutPainter extends CustomPainter {
  final double ovalWidth;
  final double ovalHeight;
  final bool isDetected;
  final double progress;

  _FaceCutoutPainter({
    required this.ovalWidth,
    required this.ovalHeight,
    required this.isDetected,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Draw background cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Glowing border around oval
    final borderPaint = Paint()
      ..color = isDetected ? AppTheme.primaryCyan : AppTheme.reviewAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BiometricMeshPainter extends CustomPainter {
  final double pulse;
  final bool isDetected;

  _BiometricMeshPainter({
    required this.pulse,
    required this.isDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isDetected) return;

    final pointPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.4 + (pulse * 0.4))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.15 + (pulse * 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2 - 20;

    // Standard simulated facial landmark points
    final points = [
      Offset(cx - 35, cy - 35), // Left eyebrow
      Offset(cx - 15, cy - 38),
      Offset(cx + 15, cy - 38),
      Offset(cx + 35, cy - 35), // Right eyebrow

      Offset(cx - 28, cy - 18), // Left eye
      Offset(cx + 28, cy - 18), // Right eye

      Offset(cx, cy - 5), // Nose bridge
      Offset(cx, cy + 18), // Nose tip
      Offset(cx - 14, cy + 22),
      Offset(cx + 14, cy + 22),

      Offset(cx - 26, cy + 45), // Mouth left
      Offset(cx + 26, cy + 45), // Mouth right
      Offset(cx, cy + 42), // Top lip
      Offset(cx, cy + 54), // Bottom lip

      Offset(cx, cy + 78), // Chin
      Offset(cx - 45, cy + 50), // Jawline left
      Offset(cx + 45, cy + 50), // Jawline right
    ];

    // Draw connecting mesh lines
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final dist = (points[i] - points[j]).distance;
        if (dist < 42) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }

    // Draw landmark points
    for (final p in points) {
      canvas.drawCircle(p, 2.8, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
