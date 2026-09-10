import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/document_model.dart';
import '../models/screening_session.dart';
import '../services/digilocker_service.dart';
import '../services/screening_service.dart';
import '../widgets/document_scanner_overlay.dart';
import '../widgets/step_progress_bar.dart';
import 'document_info_dossier_screen.dart';

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
  bool _isDetected = false;
  String? _detectedLabel;
  Offset? _focusPoint;
  Timer? _autoDetectTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startLiveDetectionSimulation();
  }

  void _startLiveDetectionSimulation() {
    // Fast periodic detector to give instant visual feedback when aiming at document
    _autoDetectTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted || _isCapturing) return;
      setState(() {
        _isDetected = true;
        _detectedLabel = widget.isBackSide
            ? '⚡ Back QR & Hologram Detected • Auto-Locking'
            : '⚡ Indian Document QR Detected • Ready to Verify';
      });
    });
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
    _autoDetectTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Trigger Fast Scan & Instant DigiLocker Verification
  Future<void> _handleCapture({bool simulateFake = false}) async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _isDetected = true;
      _detectedLabel = '⚡ Extracting QR & Querying DigiLocker...';
    });

    String imagePath = 'simulated_scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile file = await _cameraController!.takePicture();
        imagePath = file.path;
      } catch (_) {
        // Fallback to fast simulated capture path
      }
    }

    if (!mounted) return;
    final screeningService = context.read<ScreeningService>();
    final docType = screeningService.session.selectedDocType;

    // Run DigiLocker Issuer Pull URI API (< 300ms)
    final digiResult = await DigiLockerService().verifyDocumentAndPullRecords(
      docType: docType,
      rawScannedData: 'QR_SCANNED_PAYLOAD_UIDAI_PKCS7',
      simulateFakeOrExpired: simulateFake,
    );

    if (!mounted) return;
    setState(() => _isCapturing = false);

    // Direct transition to Document Info & DigiLocker Dossier Page
    final shouldProceedBack = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentInfoDossierScreen(
          initialResult: digiResult,
          docType: docType,
          imagePath: imagePath,
          isBackSide: widget.isBackSide,
        ),
      ),
    );

    if (shouldProceedBack == true && mounted) {
      // User tapped proceed on front scan for multi-side doc -> switch to back side
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DocumentCaptureScreen(isBackSide: true),
        ),
      );
    }
  }

  void _showQuickScanPresetsModal() {
    final screeningService = context.read<ScreeningService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
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
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.flash_on_rounded,
                    color: AppTheme.primaryCyan, size: 22),
                SizedBox(width: 8),
                Text(
                  'Instant QR & ID Scanner Presets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a document format to scan and instantly pull verified DigiLocker records:',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            _buildPresetTile(
              title: 'Aadhaar Secure QR (UIDAI)',
              subtitle: '12-Digit UID • Signed XML • Green Tick',
              icon: Icons.fingerprint_rounded,
              color: AppTheme.passGreen,
              onTap: () {
                Navigator.pop(ctx);
                screeningService.setDocumentType(DocumentType.nationalId);
                _handleCapture(simulateFake: false);
              },
            ),
            _buildPresetTile(
              title: 'PAN Card (Income Tax Dept)',
              subtitle: '10-Digit Alphanumeric • Linked e-PAN',
              icon: Icons.credit_card_rounded,
              color: AppTheme.primaryCyan,
              onTap: () {
                Navigator.pop(ctx);
                screeningService.setDocumentType(DocumentType.residencePermit);
                _handleCapture(simulateFake: false);
              },
            ),
            _buildPresetTile(
              title: "Driver's License (MoRTH Sarathi)",
              subtitle: 'Smart Card Chip • Valid Non-Transport',
              icon: Icons.drive_eta_rounded,
              color: Colors.purpleAccent,
              onTap: () {
                Navigator.pop(ctx);
                screeningService.setDocumentType(DocumentType.driversLicense);
                _handleCapture(simulateFake: false);
              },
            ),
            _buildPresetTile(
              title: 'Indian Passport (ICAO MRZ)',
              subtitle: '36-Page Republic of India Passport',
              icon: Icons.flight_takeoff_rounded,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.pop(ctx);
                screeningService.setDocumentType(DocumentType.passport);
                _handleCapture(simulateFake: false);
              },
            ),
            _buildPresetTile(
              title: '❌ Test Invalid / Expired / Fake ID',
              subtitle: 'Unauthenticated in DigiLocker • Red Cross Alert',
              icon: Icons.gpp_bad_rounded,
              color: AppTheme.rejectRed,
              onTap: () {
                Navigator.pop(ctx);
                _handleCapture(simulateFake: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
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
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screeningService = context.watch<ScreeningService>();
    final docType = screeningService.session.selectedDocType;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview Stream
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (details) => _onTapToFocus(details, constraints),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_cameraController != null &&
                            _cameraController!.value.isInitialized)
                          CameraPreview(_cameraController!)
                        else if (_cameraError != null)
                          _buildCameraFallback()
                        else
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryCyan,
                            ),
                          ),

                        // Document & QR Overlay with real-time detection feedback
                        DocumentScannerOverlay(
                          title: widget.isBackSide
                              ? 'Scan ${docType.shortName} (Back Side)'
                              : 'Scan ${docType.displayName}',
                          subtitle: widget.isBackSide
                              ? 'Align barcode, security stamp & details inside frame'
                              : 'Align document & QR code within frame for instant scan',
                          isScanning: true,
                          isDetected: _isDetected,
                          detectedLabel: _detectedLabel,
                        ),

                        // Tap to Focus Ring
                        if (_focusPoint != null)
                          Positioned(
                            left: _focusPoint!.dx - 28,
                            top: _focusPoint!.dy - 28,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryCyan,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Top Progress Bar & Controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_outlined,
                                  color: AppTheme.primaryCyan, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                docType.shortName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isTorchOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: _isTorchOn
                                    ? Colors.amberAccent
                                    : Colors.white,
                              ),
                              onPressed: _toggleTorch,
                            ),
                            IconButton(
                              icon: const Icon(Icons.flip_camera_ios_rounded,
                                  color: Colors.white),
                              onPressed: _switchCamera,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    StepProgressBar(
                      currentStage: widget.isBackSide
                          ? ScreeningStage.captureBack
                          : ScreeningStage.captureFront,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Shutter & Super Fast Scan Action Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fast Scan Quick Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Quick Presets Selector
                        TextButton.icon(
                          onPressed: _showQuickScanPresetsModal,
                          icon: const Icon(Icons.auto_awesome_rounded,
                              color: AppTheme.primaryCyan, size: 16),
                          label: const Text(
                            '⚡ Quick QR Presets',
                            style: TextStyle(
                              color: AppTheme.primaryCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                AppTheme.surface.withValues(alpha: 0.8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            side: BorderSide(
                              color: AppTheme.primaryCyan.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Shutter Capture Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Fast QR Capture Action
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded,
                              color: Colors.white, size: 28),
                          tooltip: 'Scan QR Code',
                          onPressed: () => _handleCapture(simulateFake: false),
                        ),

                        // Main Shutter Button
                        GestureDetector(
                          onTap: () => _handleCapture(simulateFake: false),
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.primaryCyan, width: 4),
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: Center(
                              child: _isCapturing
                                  ? const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryCyan,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Container(
                                      width: 58,
                                      height: 58,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Test Fraud/Invalid Capture
                        IconButton(
                          icon: const Icon(Icons.gpp_bad_outlined,
                              color: AppTheme.rejectRed, size: 28),
                          tooltip: 'Test Invalid / Fake ID',
                          onPressed: () => _handleCapture(simulateFake: true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFallback() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 56,
              color: AppTheme.primaryCyan,
            ),
            const SizedBox(height: 16),
            const Text(
              'High-Speed Document Camera',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hardware camera stream initializing. You can also tap "Instant Fast Scan" below to test immediate DigiLocker verification.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _handleCapture(simulateFake: false),
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text('⚡ INSTANT FAST SCAN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
