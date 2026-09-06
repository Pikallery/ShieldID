import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/verification_result.dart';
import '../services/screening_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final service = context.read<ScreeningService>();
    _urlController = TextEditingController(text: service.apiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screeningService = context.watch<ScreeningService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend Connectivity Section
            const Text(
              'Backend AI Service',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Zero-Config Mock Engine',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Simulate realistic neural inference pipelines offline without external servers',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    value: screeningService.apiService.useMockSimulation,
                    activeColor: AppTheme.primaryCyan,
                    onChanged: (val) => screeningService.setUseMockSimulation(val),
                  ),
                  const Divider(color: AppTheme.border, height: 20),
                  TextField(
                    controller: _urlController,
                    enabled: !screeningService.apiService.useMockSimulation,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'ShieldID REST Server URL',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      hintText: 'http://10.0.2.2:8000 or http://localhost:8000',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      prefixIcon: const Icon(Icons.dns_rounded, color: AppTheme.primaryCyan, size: 18),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_rounded, color: AppTheme.passGreen),
                        onPressed: () {
                          screeningService.setBaseUrl(_urlController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Endpoint updated'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Demo Simulation Target Outcome
            const Text(
              'Interactive Demo Test Target',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select next screening simulation outcome:',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildOutcomeChoice(
                        'Pass (Verified)',
                        VerificationStatus.pass,
                        screeningService,
                      ),
                      _buildOutcomeChoice(
                        'Review (Glare / Anomaly)',
                        VerificationStatus.review,
                        screeningService,
                      ),
                      _buildOutcomeChoice(
                        'Reject (Tampered Fraud)',
                        VerificationStatus.reject,
                        screeningService,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security Thresholds Section
            const Text(
              'Security Thresholds & Policies',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryCyan,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Require Hologram Tilt Check',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Mandatory optical variable ink and diffraction grating check',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    value: screeningService.requireHologramCheck,
                    activeColor: AppTheme.primaryCyan,
                    onChanged: (val) => screeningService.setRequireHologramCheck(val),
                  ),
                  const Divider(color: AppTheme.border, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fraud Sensitivity Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        screeningService.riskSensitivity < 0.35
                            ? 'Permissive'
                            : (screeningService.riskSensitivity > 0.65 ? 'High Security' : 'Balanced'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: screeningService.riskSensitivity,
                    onChanged: (val) => screeningService.setRiskSensitivity(val),
                    activeColor: AppTheme.primaryCyan,
                    inactiveColor: AppTheme.surfaceElevated,
                    divisions: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // System Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.passGreen),
                      SizedBox(width: 8),
                      Text(
                        'ShieldID Identity Screening v2.4.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Compliant with ICAO 9303, ISO/IEC 30107-3 PAD Level 2, and NIST FRS biometric standards.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeChoice(
    String label,
    VerificationStatus status,
    ScreeningService service,
  ) {
    final isSelected = service.targetSimulationStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) service.setTargetSimulationStatus(status);
      },
      selectedColor: status.color.withOpacity(0.25),
      backgroundColor: AppTheme.surfaceElevated,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? status.color : AppTheme.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? status.color : AppTheme.border,
      ),
    );
  }
}
