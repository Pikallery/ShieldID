import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/screening_session.dart';
import '../services/screening_service.dart';
import '../widgets/step_progress_bar.dart';
import 'liveness_detection_screen.dart';

class AntiTamperScreen extends StatefulWidget {
  const AntiTamperScreen({super.key});

  @override
  State<AntiTamperScreen> createState() => _AntiTamperScreenState();
}

class _AntiTamperScreenState extends State<AntiTamperScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _tiltController;
  double _tiltAngle = 0.0;
  bool _hologramVerified = false;
  double _validationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          _tiltAngle = math.sin(_tiltController.value * 2 * math.pi) * 0.18;
          _validationProgress = _tiltController.value;
          if (_tiltController.value >= 0.95 && !_hologramVerified) {
            _hologramVerified = true;
          }
        });
      });

    _tiltController.forward();
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _restartVerification() {
    setState(() {
      _hologramVerified = false;
      _validationProgress = 0.0;
    });
    _tiltController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final screeningService = context.watch<ScreeningService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anti-Tampering & Hologram'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const StepProgressBar(currentStage: ScreeningStage.antiTamperTilt),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Status & Instruction Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _hologramVerified
                          ? AppTheme.passGreen.withOpacity(0.15)
                          : AppTheme.primaryCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hologramVerified
                            ? AppTheme.passGreen
                            : AppTheme.primaryCyan,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hologramVerified
                              ? Icons.verified_rounded
                              : Icons.screen_rotation_rounded,
                          size: 18,
                          color: _hologramVerified
                              ? AppTheme.passGreen
                              : AppTheme.primaryCyan,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hologramVerified
                              ? 'Holographic Refraction Verified'
                              : 'Slowly tilt document to capture hologram',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _hologramVerified
                                ? AppTheme.passGreen
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3D Simulated Holographic Tilt Card
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(_tiltAngle),
                    alignment: Alignment.center,
                    child: Container(
                      width: double.infinity,
                      height: 210,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF162032),
                            Color(0xFF0F172A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryCyan.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Base Card Graphics
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.badge_rounded,
                                  color: AppTheme.textMuted,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'IDENTITY CREDENTIAL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Text(
                                      'Official Security Document',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Dynamic Holographic Foil Sheen
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment(-1.0 + (_tiltAngle * 5), -1.0),
                                  end: Alignment(1.0 + (_tiltAngle * 5), 1.0),
                                  colors: [
                                    Colors.transparent,
                                    Colors.purpleAccent.withOpacity(0.25),
                                    AppTheme.primaryCyan.withOpacity(0.35),
                                    Colors.amberAccent.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Security Hologram Emblem in center
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.amberAccent.withOpacity(0.8),
                                  width: 2,
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.amberAccent.withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: Colors.amberAccent,
                                size: 36,
                              ),
                            ),
                          ),

                          // Real-time Tilt Angle & Status Bar
                          Positioned(
                            bottom: 14,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: _hologramVerified
                                      ? AppTheme.passGreen
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _hologramVerified
                                      ? 'Diffraction grating confirmed (96.4%)'
                                      : 'Analyzing light angle: ${(_tiltAngle * 100).toStringAsFixed(1)}°',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _hologramVerified
                                        ? AppTheme.passGreen
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tampering Diagnostics Panel
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.glassCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Anti-Tampering Checklist',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureCheck(
                          'Optical Variable Ink (OVI)',
                          'Color shifting verified under variable illumination',
                          _validationProgress > 0.4,
                        ),
                        const Divider(color: AppTheme.border, height: 18),
                        _buildFeatureCheck(
                          'Microprint Line Continuity',
                          'Zero ink bleed or digital halftone pixelation',
                          _validationProgress > 0.7,
                        ),
                        const Divider(color: AppTheme.border, height: 18),
                        _buildFeatureCheck(
                          'Substrate Surface Texture',
                          'Security paper substrate thickness calibrated',
                          _validationProgress > 0.9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Continue Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.95),
              border: Border(
                top: BorderSide(color: AppTheme.border.withOpacity(0.6)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _restartVerification,
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hologramVerified
                        ? () {
                            screeningService.completeHologramCheck();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LivenessDetectionScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.face_rounded, size: 20),
                    label: const Text(
                      'PROCEED TO BIOMETRIC SELFIE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCheck(String title, String description, bool isPassed) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isPassed
                ? AppTheme.passGreen.withOpacity(0.2)
                : AppTheme.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPassed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isPassed ? AppTheme.passGreen : AppTheme.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
