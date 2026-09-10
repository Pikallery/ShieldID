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
  bool _isSimulatingFake = false;
  bool _isLoading = false;

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

  Future<void> _toggleSimulatedState(bool makeFake) async {
    setState(() {
      _isLoading = true;
      _isSimulatingFake = makeFake;
    });

    final newResult =
        await DigiLockerService().verifyDocumentAndPullRecords(
      docType: widget.docType,
      rawScannedData: 'simulated_payload',
      simulateFakeOrExpired: makeFake,
    );

    if (!mounted) return;
    setState(() {
      _result = newResult;
      _isLoading = false;
    });
    _animController.reset();
    _animController.forward();
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
                    'DigiLocker Issuer API v1.13 XML',
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
        title: const Text(
          'Document & Identity Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code_rounded, color: AppTheme.primaryCyan),
            tooltip: 'View DigiLocker XML',
            onPressed: _showXmlBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test Simulator Toggle (Valid vs Invalid/Fake)
                  _buildTestModeToggle(),
                  const SizedBox(height: 14),

                  // Big Prominent Green Tick / Red Cross Marker Header
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildValidityHeader(isValid, primaryColor),
                  ),
                  const SizedBox(height: 18),

                  // Person Details Card
                  _buildPersonDetailsCard(isValid, primaryColor),
                  const SizedBox(height: 18),

                  // DigiLocker Registered Documents Card
                  _buildDigiLockerCrossRegistryCard(),
                  const SizedBox(height: 18),

                  // Anomalies / Security Notes if any
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

  Widget _buildTestModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Test Verification Simulation:',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          ChoiceChip(
            label: const Text('Valid 🇮🇳', style: TextStyle(fontSize: 11)),
            selected: !_isSimulatingFake,
            selectedColor: AppTheme.passGreen.withValues(alpha: 0.25),
            onSelected: (val) {
              if (val) _toggleSimulatedState(false);
            },
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('Fake / Expired ⚠️', style: TextStyle(fontSize: 11)),
            selected: _isSimulatingFake,
            selectedColor: AppTheme.rejectRed.withValues(alpha: 0.25),
            onSelected: (val) {
              if (val) _toggleSimulatedState(true);
            },
          ),
        ],
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
                ? 'VALID & VERIFIED PERSON'
                : 'INVALID / FAKE / EXPIRED ID',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isValid
                ? 'Authenticated via DigiLocker Issuer API v1.13 • UIDAI PKCS#7 Verified'
                : 'DigiLocker Pull API Verification Failed • Unauthenticated Credentials',
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
              // Person Photo Thumbnail
              Container(
                width: 70,
                height: 85,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: primaryColor.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 46, color: AppTheme.textSecondary),
                    Positioned(
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isValid ? 'LIVE' : 'FLAG',
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

              // Name, Native Name & Primary ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _result.personName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _result.nativeName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryCyan,
                        fontWeight: FontWeight.w600,
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
                          letterSpacing: 1.0,
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

          // Detail Grid Items
          _buildDetailRow('Document Type', _result.primaryDocType),
          const SizedBox(height: 8),
          _buildDetailRow('Date of Birth', _result.dateOfBirth),
          const SizedBox(height: 8),
          _buildDetailRow('Gender', _result.gender),
          const SizedBox(height: 8),
          _buildDetailRow('Address', _result.address),
          const SizedBox(height: 8),
          _buildDetailRow('DigiLocker ID', _result.digiLockerId),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Digital Signature',
            _result.digitalSignatureValid ? 'VALID (Govt Root CA)' : 'INVALID / CORRUPTED',
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
          width: 110,
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
            'Official credentials linked to this individual across Central & State registries:',
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
                        doc.isValid ? 'MATCH' : 'MISMATCH',
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
                'Identified Discrepancies & Fraud Indicators',
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
                      : 'PROCEED WITH FRAUD LOGGING',
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
              'SCAN ANOTHER DOCUMENT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
