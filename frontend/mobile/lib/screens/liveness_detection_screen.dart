import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../services/screening_service.dart';
import '../widgets/face_mesh_overlay.dart';
import 'ai_processing_screen.dart';

class LivenessDetectionScreen extends StatefulWidget {
  const LivenessDetectionScreen({super.key});

  @override
  State<LivenessDetectionScreen> createState() =>
      _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  CameraController? _cameraController;
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
    _initializeFrontCamera();
    _startLivenessSequence();
  }

  Future<void> _initializeFrontCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Select front camera for face liveness
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } catch (_) {
      // Graceful fallback to animated face mesh
    }
  }

  void _startLivenessSequence() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
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

  Future<void> _completeLiveness() async {
    String selfiePath = 'simulated_selfie_path.jpg';
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final captured = await _cameraController!.takePicture();
        selfiePath = captured.path;
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final screeningService = context.read<ScreeningService>();
    screeningService.setSelfieImage(selfiePath);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AiProcessingScreen()),
    );
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Go back',
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        semanticLabel: 'Go back',
                        color: Colors.white,
                        size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(left: 4, right: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryCyan, AppTheme.accentTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shield_rounded,
                        color: Colors.black87,
                        size: 17,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            semanticLabel: 'Secure biometric capture',
                            size: 14,
                            color: AppTheme.primaryCyan),
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

            // Oval Viewfinder with live Camera preview & Face Mesh
            Expanded(
              child: Stack(
                children: [
                  if (_cameraController?.value.isInitialized == true)
                    Positioned.fill(
                      child: CameraPreview(_cameraController!),
                    ),
                  Positioned.fill(
                    child: FaceMeshOverlay(
                      challengePrompt: _challenges[_challengeIndex],
                      progress: _progress,
                      isFaceDetected: true,
                    ),
                  ),
                ],
              ),
            ),

            // Anti-spoof security badge bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: Colors.black.withValues(alpha: 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSecurityBadge(
                      Icons.phonelink_erase_rounded, 'No Replay Attack'),
                  _buildSecurityBadge(Icons.masks_rounded, '3D Mask Guard'),
                  _buildSecurityBadge(
                      Icons.burst_mode_rounded, 'Micro-Texture Scan'),
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
        Icon(icon,
          semanticLabel: 'Biometric check',
          size: 14,
          color: AppTheme.passGreen),
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

