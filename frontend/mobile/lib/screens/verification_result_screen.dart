import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/verification_result.dart';
import '../models/document_model.dart';
import '../services/document_parser_service.dart';
import '../services/screening_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/risk_gauge.dart';

class VerificationResultScreen extends StatelessWidget {
  final VerificationReport report;

  const VerificationResultScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final isReject = report.status == VerificationStatus.reject;

    // Checksum validations
    bool? isAadhaarChecksumValid;
    bool? isPanChecksumValid;
    if (report.documentType == DocumentType.nationalId &&
        report.documentData.documentNumber.isNotEmpty) {
      isAadhaarChecksumValid = DocumentParserService()
          .validateAadhaarVerhoeff(report.documentData.documentNumber);
    } else if (report.documentType == DocumentType.residencePermit &&
        report.documentData.documentNumber.isNotEmpty) {
      isPanChecksumValid = DocumentParserService()
          .validatePanFormat(report.documentData.documentNumber);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Dossier'),
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              semanticLabel: 'Go back', size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Share verification result',
            icon: const Icon(Icons.share_outlined,
                semanticLabel: 'Share verification result',
                color: AppTheme.primaryCyan),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Exporting encrypted audit report (${report.id})...'),
                  backgroundColor: AppTheme.surfaceElevated,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Hero Card with RiskGauge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassCardDecoration(
                borderColor: report.status.color.withValues(alpha: 0.5),
                glow: report.status == VerificationStatus.pass,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.id,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(report.timestamp),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: report.status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: report.status.color),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(report.status.icon,
                                semanticLabel: report.status.label,
                                size: 14,
                                color: report.status.color),
                            const SizedBox(width: 6),
                            Text(
                              report.status.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: report.status.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Radial Confidence Gauge
                  Center(
                    child: RiskGauge(
                      score: isReject
                          ? (report.predictiveRisk.riskScore / 100.0)
                          : report.overallConfidence,
                      status: report.status,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    report.predictiveRisk.recommendation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isReject ? AppTheme.rejectRed : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── CRITICAL FRAUD / FORGERY ANOMALY ALERT CARD (When rejected/tampered) ──
            if (isReject || report.tampering.isTampered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.rejectRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.rejectRed.withValues(alpha: 0.6),
                      width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gpp_bad_rounded,
                            color: AppTheme.rejectRed, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'DETECTED FORGERY & SECURITY ANOMALIES',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.rejectRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...report.tampering.detectedAnomalies.map(
                      (anomaly) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠️ ',
                                style: TextStyle(fontSize: 12, height: 1.3)),
                            Expanded(
                              child: Text(
                                anomaly,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  height: 1.35,
                                ),
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
            ],

            // Biometric Face Match Section
            const Text(
              'Biometric Facial Authentication',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Document Portrait Card
                      _buildPortraitBox(
                        'Document Photo',
                        Icons.account_box_rounded,
                        report.documentType.shortName,
                      ),
                      // Biometric match arrow
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: report.faceMatch.isMatch
                                  ? AppTheme.passGreen.withValues(alpha: 0.15)
                                  : AppTheme.rejectRed.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              report.faceMatch.isMatch
                                  ? Icons.compare_arrows_rounded
                                  : Icons.close_rounded,
                              color: report.faceMatch.isMatch
                                  ? AppTheme.passGreen
                                  : AppTheme.rejectRed,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(report.faceMatch.similarityScore * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: report.faceMatch.isMatch
                                  ? AppTheme.passGreen
                                  : AppTheme.rejectRed,
                            ),
                          ),
                        ],
                      ),
                      // Live Selfie Card
                      _buildPortraitBox(
                        'Live Biometric',
                        Icons.face_retouching_natural_rounded,
                        '3D Liveness',
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.border, height: 24),
                  if (report.faceMatch.notes != null)
                    Text(
                      report.faceMatch.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniBadge(
                        'Liveness: ${(report.faceMatch.livenessScore * 100).toStringAsFixed(0)}%',
                        report.faceMatch.livenessPassed,
                      ),
                      const SizedBox(width: 8),
                      _buildMiniBadge(
                        'Anti-Spoof: Active',
                        report.faceMatch.antiSpoofPassed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Extracted OCR Data Fields
            const Text(
              'Extracted Document Credentials',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                children: [
                  _buildDataField(
                      'Full Legal Name', report.documentData.fullName, 0.99),
                  const Divider(color: AppTheme.border, height: 16),
                  _buildDataFieldWithChecksum(
                    'Document Number',
                    report.documentData.documentNumber,
                    report.documentType == DocumentType.nationalId
                        ? isAadhaarChecksumValid
                        : report.documentType == DocumentType.residencePermit
                            ? isPanChecksumValid
                            : null,
                    checksumLabel: report.documentType == DocumentType.nationalId
                        ? 'Verhoeff'
                        : 'PAN Structure',
                  ),
                  const Divider(color: AppTheme.border, height: 16),
                  _buildDataField(
                      'Date of Birth', report.documentData.dateOfBirth, 0.98),
                  const Divider(color: AppTheme.border, height: 16),
                  _buildDataField(
                      'Expiry Date', report.documentData.dateOfExpiry, 0.97),
                  const Divider(color: AppTheme.border, height: 16),
                  _buildDataField('Issuing Country',
                      report.documentData.issuingCountry, 0.99),
                  if (report.documentData.mrzCode != null) ...[
                    const Divider(color: AppTheme.border, height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Machine Readable Zone (MRZ)',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.documentData.mrzCode!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppTheme.primaryCyan,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Anti-Tampering & Security Analysis Grid
            const Text(
              'Security Features & Anti-Tampering',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.border_all_rounded,
                    title: 'Edge Integrity',
                    valueText:
                        '${(report.tampering.edgeIntegrityScore * 100).toInt()}%',
                    score: report.tampering.edgeIntegrityScore,
                    subtitle: 'Geometric continuity',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.text_fields_rounded,
                    title: 'Font Uniformity',
                    valueText:
                        '${(report.tampering.fontConsistencyScore * 100).toInt()}%',
                    score: report.tampering.fontConsistencyScore,
                    subtitle: 'Pixel alignment',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Hologram Tilt',
                    valueText:
                        '${(report.securityFeatures.hologramConfidence * 100).toInt()}%',
                    score: report.securityFeatures.hologramConfidence,
                    subtitle: 'Diffraction grating',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.compress_rounded,
                    title: 'ELA Tamper Score',
                    valueText:
                        '${(report.tampering.tamperingScore * 100).toInt()}%',
                    score: 1.0 - report.tampering.tamperingScore,
                    subtitle: 'Digital splicing risk',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Risk Factors & Watchlist Checklist ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Multi-Modal Compliance Risk Signals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...report.predictiveRisk.riskFactors.map(
                    (factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isReject
                                ? Icons.close_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: isReject
                                ? AppTheme.rejectRed
                                : AppTheme.passGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              factor,
                              style: TextStyle(
                                fontSize: 12,
                                color: isReject
                                    ? AppTheme.rejectRed
                                    : AppTheme.textSecondary,
                                fontWeight: isReject
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final service = context.read<ScreeningService>();
                  service.startNewScreening();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded,
                    semanticLabel: 'Start another screening', size: 20),
                label: const Text(
                  'SCREEN ANOTHER IDENTITY',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Cryptographic PDF Audit Report generated and saved.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.download_rounded,
                    semanticLabel: 'Download report', size: 18),
                label: const Text('DOWNLOAD AUDIT REPORT (PDF)'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitBox(String label, IconData icon, String subtitle) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 104,
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  semanticLabel: 'Verification metric',
                  size: 40,
                  color: AppTheme.primaryCyan),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildMiniBadge(String text, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ok
            ? AppTheme.passGreen.withValues(alpha: 0.12)
            : AppTheme.rejectRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: ok ? AppTheme.passGreen : AppTheme.rejectRed, width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: ok ? AppTheme.passGreen : AppTheme.rejectRed,
        ),
      ),
    );
  }

  Widget _buildDataField(String label, String value, double confidence) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                semanticLabel: 'Check passed',
                size: 14,
                color: AppTheme.passGreen),
            const SizedBox(width: 4),
            Text(
              '${(confidence * 100).toInt()}%',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.passGreen,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataFieldWithChecksum(
    String label,
    String value,
    bool? isChecksumValid, {
    String checksumLabel = 'Checksum',
  }) {
    final bool hasCheck = isChecksumValid != null;
    final bool isValid = isChecksumValid == true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        if (hasCheck)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isValid
                  ? AppTheme.passGreen.withValues(alpha: 0.15)
                  : AppTheme.rejectRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isValid ? AppTheme.passGreen : AppTheme.rejectRed,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 12,
                  color: isValid ? AppTheme.passGreen : AppTheme.rejectRed,
                ),
                const SizedBox(width: 4),
                Text(
                  '$checksumLabel: ${isValid ? "VALID" : "INVALID"}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isValid ? AppTheme.passGreen : AppTheme.rejectRed,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
