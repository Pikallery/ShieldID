import 'document_model.dart';
import 'verification_result.dart';

enum ScreeningStage {
  selectDocument,
  captureFront,
  captureBack,
  antiTamperTilt,
  livenessFaceMatch,
  aiProcessing,
  completedResult;

  String get title {
    switch (this) {
      case ScreeningStage.selectDocument:
        return 'Document Type';
      case ScreeningStage.captureFront:
        return 'Document Scan';
      case ScreeningStage.captureBack:
        return 'Document Back';
      case ScreeningStage.antiTamperTilt:
        return 'Hologram Check';
      case ScreeningStage.livenessFaceMatch:
        return 'Biometric Selfie';
      case ScreeningStage.aiProcessing:
        return 'AI Analysis';
      case ScreeningStage.completedResult:
        return 'Screening Dossier';
    }
  }

  int get stepIndex {
    switch (this) {
      case ScreeningStage.selectDocument:
        return 0;
      case ScreeningStage.captureFront:
      case ScreeningStage.captureBack:
        return 1;
      case ScreeningStage.antiTamperTilt:
        return 2;
      case ScreeningStage.livenessFaceMatch:
        return 3;
      case ScreeningStage.aiProcessing:
      case ScreeningStage.completedResult:
        return 4;
    }
  }
}

class ScreeningSession {
  DocumentType selectedDocType;
  String issuingCountry;
  String? frontImagePath;
  String? backImagePath;
  String? selfieImagePath;
  bool hologramChecked;
  ScreeningStage stage;
  VerificationReport? report;
  double processingProgress;
  String currentAiTask;

  ScreeningSession({
    this.selectedDocType = DocumentType.passport,
    this.issuingCountry = 'United States',
    this.frontImagePath,
    this.backImagePath,
    this.selfieImagePath,
    this.hologramChecked = false,
    this.stage = ScreeningStage.selectDocument,
    this.report,
    this.processingProgress = 0.0,
    this.currentAiTask = 'Initializing AI pipeline...',
  });

  void reset() {
    selectedDocType = DocumentType.passport;
    issuingCountry = 'United States';
    frontImagePath = null;
    backImagePath = null;
    selfieImagePath = null;
    hologramChecked = false;
    stage = ScreeningStage.selectDocument;
    report = null;
    processingProgress = 0.0;
    currentAiTask = 'Initializing AI pipeline...';
  }
}
