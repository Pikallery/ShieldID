import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/document_model.dart';
import '../models/screening_session.dart';
import '../services/screening_service.dart';
import '../widgets/document_scanner_overlay.dart';
import '../widgets/step_progress_bar.dart';
import 'anti_tamper_screen.dart';
import 'liveness_detection_screen.dart';

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
  bool _isTorchOn = false;
  bool _isCapturing = false;

  void _handleCapture() async {
    setState(() => _isCapturing = true);

    // Simulate shutter feedback
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isCapturing = false);

    _showPreviewConfirmationModal();
  }

  void _showPreviewConfirmationModal() {
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
                      color: AppTheme.passGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.passGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isBackSide ? 'Back Scan Captured' : 'Front Scan Captured',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Simulated captured image preview container
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      widget.isBackSide ? Icons.subtitles_rounded : Icons.account_box_rounded,
                      size: 64,
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: AppTheme.passGreen),
                            const SizedBox(width: 8),
                            Text(
                              'Auto-Quality: 98% • No glare • All 4 corners detected',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textPrimary.withOpacity(0.9),
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
              const SizedBox(height: 20),

              // Quality Checklist
              _buildQualityItem('Text & numbers are razor sharp', true),
              const SizedBox(height: 8),
              _buildQualityItem('No holographic flash glare obstructing data', true),
              const SizedBox(height: 8),
              _buildQualityItem('Document edges match security perspective', true),
              const SizedBox(height: 24),

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
                        _proceedAfterCapture(screeningService, docType);
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
                            : (docType.requiresBackSide ? 'PROCEED TO BACK' : 'CONFIRM & NEXT'),
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

  void _proceedAfterCapture(ScreeningService screeningService, DocumentType docType) {
    if (!widget.isBackSide) {
      screeningService.setFrontImage('simulated_front_path.jpg');
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
      screeningService.setBackImage('simulated_back_path.jpg');
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
    final docType = screeningService.session.selectedDocType;

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

            // Top Bar with Torch & Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: _isTorchOn ? AppTheme.primaryCyan : Colors.white70,
                      size: 24,
                    ),
                    onPressed: () => setState(() => _isTorchOn = !_isTorchOn),
                  ),
                ],
              ),
            ),

            // Viewfinder Area with Document Overlay
            Expanded(
              child: Stack(
                children: [
                  // Simulated Camera Feed Background
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0A0F1D)],
                        radius: 1.2,
                      ),
                    ),
                  ),

                  // Scanner Frame with Animated Laser Beam
                  DocumentScannerOverlay(
                    title: widget.isBackSide
                        ? 'Scan Document Back'
                        : 'Scan Document Front',
                    subtitle: widget.isBackSide
                        ? 'Align barcode/magnetic strip inside frame'
                        : 'Align ${docType.shortName} inside brackets',
                  ),
                ],
              ),
            ),

            // Bottom Shutter Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
              color: Colors.black.withOpacity(0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery picker button
                  IconButton(
                    onPressed: _handleCapture,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white70,
                      size: 28,
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
                        border: Border.all(color: AppTheme.primaryCyan, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Info button
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Position document within frame. Camera auto-focuses.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white70,
                      size: 28,
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
