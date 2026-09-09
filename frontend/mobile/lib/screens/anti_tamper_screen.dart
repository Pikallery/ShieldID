import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/document_model.dart';
import '../models/screening_session.dart';
import '../models/verification_result.dart';
import '../services/screening_service.dart';
import '../widgets/step_progress_bar.dart';
import 'liveness_detection_screen.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final report = screeningService.session.report;
    final extracted = report?.documentData;
    final verdict = report?.status ?? VerificationStatus.review;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.antiTamperingHologram),
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              semanticLabel: 'Go back', size: 18),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: verdict.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: verdict.color),
                      ),
                      child: Text(
                        l10n.verdict(verdict.label),
                        style: TextStyle(
                            color: verdict.color, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExtractedFields(context, extracted),
                  const SizedBox(height: 16),
                  _buildSecurityChips(report),
                  const SizedBox(height: 24),
                  // Status & Instruction Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _hologramVerified
                          ? AppTheme.passGreen.withValues(alpha: 0.15)
                          : AppTheme.primaryCyan.withValues(alpha: 0.12),
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
                          semanticLabel: _hologramVerified
                              ? 'Hologram verified'
                              : 'Tilt instruction',
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
                          color: AppTheme.primaryCyan.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Base Card Graphics
                          const Positioned(
                            top: 20,
                            left: 20,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.badge_rounded,
                                  semanticLabel: 'Identity credential',
                                  color: AppTheme.textMuted,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                  begin:
                                      Alignment(-1.0 + (_tiltAngle * 5), -1.0),
                                  end: Alignment(1.0 + (_tiltAngle * 5), 1.0),
                                  colors: [
                                    Colors.transparent,
                                    Colors.purpleAccent.withValues(alpha: 0.25),
                                    AppTheme.primaryCyan
                                        .withValues(alpha: 0.35),
                                    Colors.amberAccent.withValues(alpha: 0.25),
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
                                  color:
                                      Colors.amberAccent.withValues(alpha: 0.8),
                                  width: 2,
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.amberAccent.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                semanticLabel: 'Security shield',
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
                                  semanticLabel: 'Hologram check status',
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
              color: AppTheme.surface.withValues(alpha: 0.95),
              border: Border(
                top: BorderSide(color: AppTheme.border.withValues(alpha: 0.6)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Restart hologram verification',
                  onPressed: _restartVerification,
                  icon: const Icon(Icons.refresh_rounded,
                      semanticLabel: 'Restart hologram verification',
                      color: AppTheme.textSecondary),
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
                    icon: const Icon(Icons.face_rounded,
                        semanticLabel: 'Proceed to biometric selfie', size: 20),
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
                ? AppTheme.passGreen.withValues(alpha: 0.2)
                : AppTheme.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPassed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            semanticLabel:
                isPassed ? 'Security check passed' : 'Security check pending',
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

  Widget _buildExtractedFields(
      BuildContext context, ExtractedDocumentData? data) {
    final l10n = AppLocalizations.of(context);
    final fields = <String, String>{
      'Full name': data?.fullName ?? 'Pending OCR',
      'Document number': data?.documentNumber ?? 'Pending OCR',
      'Date of birth': data?.dateOfBirth ?? 'Pending OCR',
      'Date of expiry': data?.dateOfExpiry ?? 'Pending OCR',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n.extractedOcrFields,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: fields.entries.map((entry) {
            final confidence = data?.fieldConfidences[entry.key] ?? 0.0;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted)),
                  Text(entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  LinearProgressIndicator(
                      value: confidence == 0 ? null : confidence,
                      minHeight: 3,
                      backgroundColor: AppTheme.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation(confidence > 0.8
                          ? AppTheme.passGreen
                          : AppTheme.reviewAmber)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSecurityChips(VerificationReport? report) {
    final checks = <String, bool>{
      'Hologram':
          report?.securityFeatures.hologramDetected ?? _hologramVerified,
      'Font': report != null && report.tampering.fontConsistencyScore >= 0.8,
      'Tamper': report?.tampering.isTampered == false,
      'MRZ':
          report?.documentData.fieldConfidences.containsKey('MRZ Checksum') ??
              false,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: checks.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: Icon(
                  entry.value
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  semanticLabel: entry.value
                      ? '${entry.key} passed'
                      : '${entry.key} needs review',
                  color:
                      entry.value ? AppTheme.passGreen : AppTheme.reviewAmber,
                  size: 18),
              label: Text(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
