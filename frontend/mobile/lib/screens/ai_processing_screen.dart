import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/screening_session.dart';
import '../services/screening_service.dart';
import 'verification_result_screen.dart';

class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({super.key});

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screeningService = context.watch<ScreeningService>();
    final session = screeningService.session;

    // Check if processing completed
    if (session.stage == ScreeningStage.completedResult && session.report != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationResultScreen(report: session.report!),
          ),
        );
      });
    }

    final tasks = [
      {'title': 'OCR & MRZ Extraction', 'threshold': 0.25, 'icon': Icons.text_snippet_outlined},
      {'title': 'Anti-Tampering & ELA Check', 'threshold': 0.50, 'icon': Icons.fingerprint_rounded},
      {'title': 'Biometric Face Match (512-d)', 'threshold': 0.75, 'icon': Icons.face_rounded},
      {'title': 'Predictive Risk Scoring Engine', 'threshold': 0.95, 'icon': Icons.analytics_outlined},
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header title
              const Text(
                'ShieldID Neural Engine',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Running multi-layer identity authentication pipeline',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),

              // Futuristic Concentric Rotating Radar Graphic
              SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _NeuralRadarPainter(
                        rotation: _radarController.value * 2 * math.pi,
                        progress: session.processingProgress,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Active task and percentage indicator
              Text(
                '${(session.processingProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryCyan,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.4)),
                ),
                child: Text(
                  session.currentAiTask,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Spacer(),

              // Processing Stages Checklist
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.glassCardDecoration(),
                child: Column(
                  children: tasks.map((task) {
                    final threshold = task['threshold'] as double;
                    final isComplete = session.processingProgress >= threshold;
                    final isCurrent = !isComplete && (session.processingProgress >= threshold - 0.25);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? AppTheme.passGreen.withOpacity(0.15)
                                  : (isCurrent
                                      ? AppTheme.primaryCyan.withOpacity(0.15)
                                      : AppTheme.surfaceElevated),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isComplete
                                  ? Icons.check
                                  : (task['icon'] as IconData),
                              size: 16,
                              color: isComplete
                                  ? AppTheme.passGreen
                                  : (isCurrent ? AppTheme.primaryCyan : AppTheme.textMuted),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task['title'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrent || isComplete
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isComplete
                                    ? AppTheme.textPrimary
                                    : (isCurrent
                                        ? AppTheme.primaryCyan
                                        : AppTheme.textMuted),
                              ),
                            ),
                          ),
                          if (isComplete)
                            const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.passGreen,
                              ),
                            )
                          else if (isCurrent)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryCyan,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeuralRadarPainter extends CustomPainter {
  final double rotation;
  final double progress;

  _NeuralRadarPainter({required this.rotation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Concentric rings
    final ringPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, maxRadius * 0.35, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.65, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.95, ringPaint);

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx - maxRadius, center.dy),
        Offset(center.dx + maxRadius, center.dy), crosshairPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius),
        Offset(center.dx, center.dy + maxRadius), crosshairPaint);

    // Rotating Radar Sweep Shader
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.primaryCyan.withOpacity(0.0),
          AppTheme.primaryCyan.withOpacity(0.4),
        ],
        stops: const [0.0, 0.7, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius * 0.95, sweepPaint);

    // Center pulsating core
    final corePaint = Paint()
      ..color = AppTheme.primaryCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, corePaint);

    final glowPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _NeuralRadarPainter oldDelegate) => true;
}
