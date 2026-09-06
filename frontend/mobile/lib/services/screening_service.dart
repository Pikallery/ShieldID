import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/screening_session.dart';
import '../models/verification_result.dart';
import 'api_service.dart';
import 'mock_data.dart';

class ScreeningService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ScreeningSession _session = ScreeningSession();
  List<VerificationReport> _history = [];

  // App Settings
  double _riskSensitivity = 0.5; // 0.0 to 1.0
  bool _requireHologramCheck = true;
  VerificationStatus _targetSimulationStatus = VerificationStatus.pass;

  ScreeningService() {
    _history = MockData.getInitialHistory();
  }

  // Getters
  ScreeningSession get session => _session;
  List<VerificationReport> get history => _history;
  ApiService get apiService => _apiService;
  double get riskSensitivity => _riskSensitivity;
  bool get requireHologramCheck => _requireHologramCheck;
  VerificationStatus get targetSimulationStatus => _targetSimulationStatus;

  // Settings Setters
  void setBaseUrl(String url) {
    _apiService.baseUrl = url;
    notifyListeners();
  }

  void setUseMockSimulation(bool val) {
    _apiService.useMockSimulation = val;
    notifyListeners();
  }

  void setRiskSensitivity(double val) {
    _riskSensitivity = val;
    notifyListeners();
  }

  void setRequireHologramCheck(bool val) {
    _requireHologramCheck = val;
    notifyListeners();
  }

  void setTargetSimulationStatus(VerificationStatus status) {
    _targetSimulationStatus = status;
    notifyListeners();
  }

  // Workflow Navigation & Actions
  void startNewScreening() {
    _session.reset();
    notifyListeners();
  }

  void setDocumentType(DocumentType type, {String country = 'United States'}) {
    _session.selectedDocType = type;
    _session.issuingCountry = country;
    _session.stage = ScreeningStage.captureFront;
    notifyListeners();
  }

  void setFrontImage(String path) {
    _session.frontImagePath = path;
    if (_session.selectedDocType.requiresBackSide) {
      _session.stage = ScreeningStage.captureBack;
    } else if (_requireHologramCheck) {
      _session.stage = ScreeningStage.antiTamperTilt;
    } else {
      _session.stage = ScreeningStage.livenessFaceMatch;
    }
    notifyListeners();
  }

  void setBackImage(String path) {
    _session.backImagePath = path;
    if (_requireHologramCheck) {
      _session.stage = ScreeningStage.antiTamperTilt;
    } else {
      _session.stage = ScreeningStage.livenessFaceMatch;
    }
    notifyListeners();
  }

  void completeHologramCheck() {
    _session.hologramChecked = true;
    _session.stage = ScreeningStage.livenessFaceMatch;
    notifyListeners();
  }

  void setSelfieImage(String path) {
    _session.selfieImagePath = path;
    _session.stage = ScreeningStage.aiProcessing;
    notifyListeners();
    _triggerAiAnalysis();
  }

  Future<void> _triggerAiAnalysis() async {
    _session.processingProgress = 0.05;
    _session.currentAiTask = 'Submitting artifacts to ShieldID Neural Engine...';
    notifyListeners();

    try {
      final report = await _apiService.runVerificationPipeline(
        docType: _session.selectedDocType,
        frontImagePath: _session.frontImagePath,
        backImagePath: _session.backImagePath,
        selfieImagePath: _session.selfieImagePath,
        targetSimulationStatus: _targetSimulationStatus,
        onProgressUpdate: (progress, task) {
          _session.processingProgress = progress;
          _session.currentAiTask = task;
          notifyListeners();
        },
      );

      _session.report = report;
      _session.stage = ScreeningStage.completedResult;
      _history.insert(0, report);
      notifyListeners();
    } catch (e) {
      _session.currentAiTask = 'Error: $e';
      notifyListeners();
    }
  }

  void setStage(ScreeningStage stage) {
    _session.stage = stage;
    notifyListeners();
  }
}
