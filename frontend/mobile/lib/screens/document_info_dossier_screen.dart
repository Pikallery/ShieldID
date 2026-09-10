import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/digilocker_model.dart';
import '../models/document_model.dart';
import '../services/digilocker_service.dart';
import '../services/screening_service.dart';
import 'anti_tamper_screen.dart';
import 'liveness_detection_screen.dart';

class DocumentInfoDossierScreen extends StatefulWidget {
  final DigiLockerVerificationResult initialResult;
  final DocumentType docType;
  final String imagePath;
  final bool isBackSide;

  const DocumentInfoDossierScreen({
    super.key,
    required this.initialResult,
    required this.docType,
    required this.imagePath,
    this.isBackSide = false,
  });

  @override
  State<DocumentInfoDossierScreen> createState() =>
      _DocumentInfoDossierScreenState();
}

class _DocumentInfoDossierScreenState extends State<DocumentInfoDossierScreen>
    with SingleTickerProviderStateMixin {
  late DigiLockerVerificationResult _result;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showXmlBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                  Icon(Icons.code_rounded,
                      color: AppTheme.primaryCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DigiLocker Issuer API v1.13 XML Verification',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: SelectableText(
                      _result.rawXmlPayload,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF38BDF8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToNextStep() {
    final screeningService = context.read<ScreeningService>();

    if (!widget.isBackSide) {
      screeningService.setFrontImage(widget.imagePath);
      if (widget.docType.requiresBackSide) {
        Navigator.pop(context, true); // Pop back to capture screen for back side
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
      screeningService.setBackImage(widget.imagePath);
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

  @override
  Widget build(BuildContext context) {
    final isValid = _result.isValidPerson;
    final primaryColor = isValid ? AppTheme.passGreen : AppTheme.rejectRed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
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
            const Expanded(
              child: Text(
                'Document & Identity Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code_rounded, color: AppTheme.primaryCyan),
            tooltip: 'View DigiLocker XML',
            onPressed: _showXmlBottomSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Prominent Green Tick / Red Cross Marker Header
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildValidityHeader(isValid, primaryColor),
            ),
            const SizedBox(height: 18),

            // Person Details Card with actual captured image & extracted data
            _buildPersonDetailsCard(isValid, primaryColor),
            const SizedBox(height: 18),

            // DigiLocker Registered Documents Card
            _buildDigiLockerCrossRegistryCard(),
            const SizedBox(height: 18),

            // Anomalies / Discrepancies if any
            if (_result.verificationAnomalies.isNotEmpty) ...[
              _buildAnomaliesCard(),
              const SizedBox(height: 18),
            ],

            // Action Buttons
            _buildActionButtons(isValid),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildValidityHeader(bool isValid, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.18),
            AppTheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.15),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Large Glowing Icon: Green Tick or Red Cross
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.2),
              border: Border.all(color: primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isValid ? Icons.check_rounded : Icons.close_rounded,
                size: 46,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isValid
                ? 'GENUINE & VERIFIED DOCUMENT'
                : 'DOCUMENT UNVERIFIED / UNREADABLE',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isValid
                ? 'Structure & Checksums Verified • DigiLocker Issuer API v1.13 Authenticated'
                : 'Document details could not be authenticated against Central Registry standards',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonDetailsCard(bool isValid, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Document Capture Preview Thumbnail
              Container(
                width: 80,
                height: 95,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: primaryColor.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.imagePath.isNotEmpty && !widget.imagePath.startsWith('simulated_'))
                      (kIsWeb
                          ? Image.network(widget.imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.document_scanner_rounded, size: 40, color: AppTheme.textSecondary))
                          : Image.file(File(widget.imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.document_scanner_rounded, size: 40, color: AppTheme.textSecondary)))
                    else
                      const Center(
                        child: Icon(Icons.document_scanner_rounded,
                            size: 40, color: AppTheme.textSecondary),
                      ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isValid ? 'GENUINE' : 'FLAGGED',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Name & Primary Document Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _showManualEntryModal,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _result.personName.trim().isNotEmpty
                                  ? _result.personName
                                  : 'Cardholder Name (Tap to Edit)',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: _result.personName.trim().isNotEmpty
                                    ? AppTheme.textPrimary
                                    : AppTheme.primaryCyan,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_note_rounded,
                            color: AppTheme.primaryCyan,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        _result.primaryDocNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 14),

          // Real Document Fields
          _buildDetailRow('Document Type', _result.primaryDocType),
          const SizedBox(height: 8),
          _buildDetailRow('Date of Birth', _result.dateOfBirth),
          const SizedBox(height: 8),
          _buildDetailRow('Gender', _result.gender),
          const SizedBox(height: 8),
          _buildDetailRow('DigiLocker ID', _result.digiLockerId),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Cryptographic Signature',
            _result.digitalSignatureValid ? 'VALID (Govt Root CA)' : 'UNVERIFIED / UNREADABLE',
            customColor: _result.digitalSignatureValid
                ? AppTheme.passGreen
                : AppTheme.rejectRed,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? customColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: customColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigiLockerCrossRegistryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded,
                  color: AppTheme.primaryCyan, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Cross-Registered Documents in DigiLocker',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_result.activeVerifiedDocuments}/${_result.totalLinkedDocuments} VERIFIED',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Official government registries cross-referenced for this genuine cardholder:',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          // List of Linked Documents
          ..._result.registeredDocuments.map((doc) => _buildLinkedDocTile(doc)),
        ],
      ),
    );
  }

  Widget _buildLinkedDocTile(DigiLockerLinkedDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: doc.isValid
              ? AppTheme.border
              : AppTheme.rejectRed.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: doc.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(doc.icon, color: doc.statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.docName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: doc.statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doc.isValid ? 'MATCH' : 'UNMATCHED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: doc.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.issuerName} • ${doc.documentNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.statusDescription,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: doc.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.rejectRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.rejectRed.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.report_problem_rounded,
                  color: AppTheme.rejectRed, size: 18),
              SizedBox(width: 8),
              Text(
                'Verification Notice & Discrepancies',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.rejectRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._result.verificationAnomalies.map(
            (anomaly) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppTheme.rejectRed,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      anomaly,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryModal() {
    final nameCtrl = TextEditingController(
      text: _result.personName == 'Unidentified Cardholder' || _result.personName == 'Authenticated Cardholder'
          ? ''
          : _result.personName,
    );
    final numCtrl = TextEditingController(
      text: _result.primaryDocNumber == 'Scan Incomplete / Unreadable'
          ? ''
          : _result.primaryDocNumber,
    );
    final dobCtrl = TextEditingController(
      text: _result.dateOfBirth == 'On File with Issuer'
          ? ''
          : _result.dateOfBirth,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded,
                    color: AppTheme.primaryCyan, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Confirm / Enter Document Details',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Full Name (as printed on card)',
                hintText: 'e.g. SAI PRADYUMNA SAMAL',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppTheme.primaryCyan),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: '${widget.docType.shortName} Number',
                hintText: widget.docType == DocumentType.residencePermit
                    ? 'e.g. ABCPS1234F'
                    : '12-digit UID or ID number',
                prefixIcon: const Icon(Icons.badge_outlined,
                    color: AppTheme.primaryCyan),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dobCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Date of Birth (DD/MM/YYYY)',
                hintText: 'e.g. 31/10/2005',
                prefixIcon:
                    Icon(Icons.cake_outlined, color: AppTheme.primaryCyan),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final manualData = ExtractedDocumentData(
                    documentNumber: numCtrl.text.trim().toUpperCase(),
                    fullName: nameCtrl.text.trim().toUpperCase(),
                    dateOfBirth: dobCtrl.text.trim(),
                    dateOfExpiry: '',
                    dateOfIssue: '',
                    gender: 'Specified in Registry',
                    nationality: 'Indian',
                    issuingCountry: 'India',
                  );
                  final updatedResult =
                      await DigiLockerService().verifyDocumentAndPullRecords(
                    docType: widget.docType,
                    extractedData: manualData,
                    imagePath: widget.imagePath,
                  );
                  setState(() {
                    _result = updatedResult;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('AUTHENTICATE WITH DIGILOCKER',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isValid) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _proceedToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isValid ? AppTheme.primaryCyan : AppTheme.rejectRed,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isValid
                      ? 'PROCEED TO BIOMETRIC VERIFICATION'
                      : 'PROCEED TO MANUAL INSPECTION',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _showManualEntryModal,
            icon: const Icon(Icons.edit_note_rounded,
                color: AppTheme.primaryCyan, size: 18),
            label: const Text(
              'CONFIRM / EDIT DETAILS MANUALLY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.primaryCyan,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryCyan),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'RE-SCAN DOCUMENT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
