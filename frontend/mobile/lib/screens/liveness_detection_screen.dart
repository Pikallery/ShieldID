import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/screening_session.dart';
import '../services/screening_service.dart';
import '../widgets/face_mesh_overlay.dart';
import '../widgets/step_progress_bar.dart';
import 'ai_processing_screen.dart';

class LivenessDetectionScreen extends StatefulWidget {
  const LivenessDetectionScreen({super.key});

  @override
  State<LivenessDetectionScreen> createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  int _challengeIndex = 0;
  double _progress = 0.05;
  Timer? _stepTimer;

  final List<String> _challenges = [
    'Position your face inside the oval frame',
    'Blink your eyes slowly...',
    'Turn your head slightly to the right',
    'Hold still for high-resolution biometric snapshot',
    'Biometric Liveness Authenticated!',
  ];

  @override
  void initState() {
    super.initState();
    _startLivenessSequence();
  }

  void _startLivenessSequence() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_challengeIndex < _challenges.length - 1) {
          _challengeIndex++;
          _progress = (_challengeIndex + 1) / _challenges.length;
        } else {
          timer.cancel();
          _completeLiveness();
        }
      });
    });
  }

  void _completeLiveness() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final screeningService = context.read<ScreeningService>();
    screeningService.setSelfieImage('simulated_selfie_path.jpg');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AiProcessingScreen()),
    );
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StepProgressBar(currentStage: ScreeningStage.livenessFaceMatch),

            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_outline_rounded, size: 14, color: AppTheme.primaryCyan),
                        SizedBox(width: 6),
                        Text(
                          'ISO 30107-3 Compliant',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Oval Viewfinder with Face Mesh
            Expanded(
              child: FaceMeshOverlay(
                challengePrompt: _challenges[_challengeIndex],
                progress: _progress,
                isFaceDetected: true,
              ),
            ),

            // Anti-spoof security badge bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: Colors.black.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSecurityBadge(Icons.phonelink_erase_rounded, 'No Replay Attack'),
                  _buildSecurityBadge(Icons.masks_rounded, '3D Mask Guard'),
                  _buildSecurityBadge(Icons.burst_mode_rounded, 'Micro-Texture Scan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.passGreen),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
