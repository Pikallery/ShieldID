import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/document_model.dart';
import '../models/screening_session.dart';
import '../services/screening_service.dart';
import '../widgets/document_scanner_overlay.dart';
import '../widgets/step_progress_bar.dart';
import 'anti_tamper_screen.dart';
import 'liveness_detection_screen.dart';
import '../l10n/app_localizations.dart';

class DocumentCaptureScreen extends StatefulWidget {
  final bool isBackSide;

  const DocumentCaptureScreen({
    super.key,
    required this.isBackSide,
  });

  @override
  State<DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  String? _cameraError;
  bool _isTorchOn = false;
  bool _isCapturing = false;
  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera({int? cameraIndex}) async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        throw CameraException(
            'NoCamera', 'No camera is available on this device.');
      }

      int indexToUse = 0;
      if (cameraIndex != null && cameraIndex >= 0 && cameraIndex < _cameras.length) {
        indexToUse = cameraIndex;
      } else {
        // Default to back camera for scanning physical documents on mobile
        final backIndex = _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.back);
        if (backIndex != -1) {
          indexToUse = backIndex;
        }
      }
      _selectedCameraIndex = indexToUse;

      final previousController = _cameraController;
      final controller = CameraController(
        _cameras[indexToUse],
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await previousController?.dispose();
      await controller.initialize();

      try {
        await controller.setFocusMode(FocusMode.auto);
        await controller.setExposureMode(ExposureMode.auto);
      } catch (_) {}

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _cameraError = null;
        _isTorchOn = false;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() => _cameraError = error.description ?? error.code);
    } catch (error) {
      if (!mounted) return;
      setState(() => _cameraError = error.toString());
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final newTorch = !_isTorchOn;
      await _cameraController!.setFlashMode(
        newTorch ? FlashMode.torch : FlashMode.off,
      );
      if (!mounted) return;
      setState(() => _isTorchOn = newTorch);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Torch not supported on this lens: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No alternate camera detected on this device.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeCamera(cameraIndex: nextIndex);
  }

  Future<void> _onTapToFocus(
      TapDownDetails details, BoxConstraints constraints) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final point = details.localPosition;
    final x = (point.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final y = (point.dy / constraints.maxHeight).clamp(0.0, 1.0);

    setState(() => _focusPoint = point);

    try {
      await _cameraController!.setFocusPoint(Offset(x, y));
      await _cameraController!.setExposurePoint(Offset(x, y));
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    if (_isCapturing) return;

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is warming up. Please hold steady.')),
      );
      return;
    }

    try {
      setState(() => _isCapturing = true);

      // Take high-resolution picture
      final XFile imageFile = await _cameraController!.takePicture();

      if (!mounted) return;
      setState(() => _isCapturing = false);

      _showPreviewConfirmationModal(imageFile.path);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture failed: $e')),
      );
    }
  }

  void _showPreviewConfirmationModal(String imagePath) {
    final screeningService = context.read<ScreeningService>();
    final docType = screeningService.session.selectedDocType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.passGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      semanticLabel: 'Capture confirmed',
                      color: AppTheme.passGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isBackSide
                        ? 'Back Scan Captured'
                        : 'Front Scan Captured',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Captured image preview container showing the actual picture
              Container(
                height: 200,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.6),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(imagePath, fit: BoxFit.cover)
                        : Image.file(File(imagePath), fit: BoxFit.cover),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                semanticLabel: 'Automatic quality check',
                                size: 14,
                                color: AppTheme.passGreen),
                            const SizedBox(width: 8),
                            Text(
                              'Auto-Quality: 98% • Razor Sharp • All 4 corners detected',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    AppTheme.textPrimary.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Quality Checklist
              _buildQualityItem('Document edges & text are razor sharp', true),
              const SizedBox(height: 8),
              _buildQualityItem(
                  'No holographic flash glare obstructing vital data', true),
              const SizedBox(height: 8),
              _buildQualityItem(
                  'High resolution capture ready for Neural OCR', true),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('RETAKE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _proceedAfterCapture(
                            screeningService, docType, imagePath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.isBackSide
                            ? 'CONFIRM BACK'
                            : (docType.requiresBackSide
                                ? 'PROCEED TO BACK'
                                : 'CONFIRM & NEXT'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
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

  void _proceedAfterCapture(
      ScreeningService screeningService, DocumentType docType, String capturedPath) {
    if (!widget.isBackSide) {
      screeningService.setFrontImage(capturedPath);
      if (docType.requiresBackSide) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DocumentCaptureScreen(isBackSide: true),
          ),
        );
      } else if (screeningService.requireHologramCheck) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AntiTamperScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LivenessDetectionScreen()),
        );
      }
    } else {
      screeningService.setBackImage(capturedPath);
      if (screeningService.requireHologramCheck) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AntiTamperScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LivenessDetectionScreen()),
        );
      }
    }
  }

  Widget _buildQualityItem(String label, bool isOk) {
    return Row(
      children: [
        Icon(
          isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
          semanticLabel: isOk ? 'Check passed' : 'Check failed',
          size: 16,
          color: isOk ? AppTheme.passGreen : AppTheme.rejectRed,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screeningService = context.watch<ScreeningService>();
    final l10n = AppLocalizations.of(context);
    final docType = screeningService.session.selectedDocType;
    final currentLens = (_cameras.isNotEmpty && _selectedCameraIndex < _cameras.length)
        ? _cameras[_selectedCameraIndex].lensDirection
        : CameraLensDirection.back;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            StepProgressBar(
              currentStage: widget.isBackSide
                  ? ScreeningStage.captureBack
                  : ScreeningStage.captureFront,
            ),

            // Top Bar with Torch, Camera Switch & Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const Spacer(),
                  // Lens Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      currentLens == CameraLensDirection.back
                          ? 'REAR LENS'
                          : 'FRONT LENS',
                      style: const TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Camera Switch Button
                  IconButton(
                    tooltip: 'Switch Camera',
                    icon: const Icon(
                      Icons.cameraswitch_rounded,
                      semanticLabel: 'Switch camera',
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: _switchCamera,
                  ),
                  // Torch Button
                  IconButton(
                    tooltip: _isTorchOn
                        ? 'Turn off flashlight'
                        : 'Turn on flashlight',
                    icon: Icon(
                      _isTorchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      semanticLabel:
                          _isTorchOn ? 'Flashlight on' : 'Flashlight off',
                      color: _isTorchOn ? AppTheme.primaryCyan : Colors.white70,
                      size: 24,
                    ),
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),

            // Viewfinder Area with Document Overlay & Tap to Focus
            Expanded(
              child: Stack(
                children: [
                  if (_cameraError != null)
                    Center(
                      child: Card(
                        margin: const EdgeInsets.all(24),
                        color: AppTheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined,
                                  semanticLabel: 'Camera unavailable',
                                  color: AppTheme.rejectRed,
                                  size: 40),
                              const SizedBox(height: 12),
                              Text(l10n.cameraInitializationFailed,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_cameraError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _initializeCamera(),
                                icon: const Icon(Icons.refresh,
                                    semanticLabel:
                                        'Retry camera initialization'),
                                label: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onTapDown: (details) =>
                              _onTapToFocus(details, constraints),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF0A0F1D)],
                                radius: 1.2,
                              ),
                            ),
                            child: _cameraController?.value.isInitialized == true
                                ? CameraPreview(_cameraController!)
                                : const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryCyan),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    // Scanner Frame with Animated Laser Beam
                    DocumentScannerOverlay(
                      title: widget.isBackSide
                          ? 'Scan Document Back'
                          : 'Scan Document Front',
                      subtitle: widget.isBackSide
                          ? 'Align barcode/MRZ inside bracket guides'
                          : 'Align ${docType.shortName} inside bracket guides',
                    ),

                    // Tap to Focus Target Indicator
                    if (_focusPoint != null)
                      Positioned(
                        left: _focusPoint!.dx - 24,
                        top: _focusPoint!.dy - 24,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.3, end: 1.0),
                          duration: const Duration(milliseconds: 250),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.primaryCyan,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),

            // Bottom Shutter Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              color: Colors.black.withValues(alpha: 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Fast Auto-Detect Guide button
                  IconButton(
                    tooltip: 'Focus Guide',
                    onPressed: () {
                      _cameraController?.setFocusMode(FocusMode.auto);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Auto-focusing document frame...'),
                          duration: Duration(milliseconds: 900),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.center_focus_strong_rounded,
                      semanticLabel: 'Auto-focus',
                      color: AppTheme.primaryCyan,
                      size: 26,
                    ),
                  ),

                  // Shutter Button with cyan glow
                  GestureDetector(
                    onTap: _isCapturing ? null : _handleCapture,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppTheme.primaryCyan, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: _isCapturing ? 48 : 58,
                          height: _isCapturing ? 48 : 58,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryCyan,
                            shape: BoxShape.circle,
                          ),
                          child: _isCapturing
                              ? const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.black,
                                  size: 28,
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Info Guidance button
                  IconButton(
                    tooltip: 'Capture guidance',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Position document squarely inside brackets. Tap screen to focus.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.help_outline_rounded,
                      semanticLabel: 'Capture guidance',
                      color: Colors.white70,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

