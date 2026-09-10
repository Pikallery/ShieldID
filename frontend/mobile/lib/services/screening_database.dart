import '../models/screening_session.dart';
import '../models/verification_result.dart';

class ScreeningDatabase {
  ScreeningDatabase._();

  static final instance = ScreeningDatabase._();
  final List<VerificationReport> _reports = [];

  Future<List<VerificationReport>> loadReports() async {
    return List<VerificationReport>.from(_reports);
  }

  Future<void> saveSession(ScreeningSession session) async {
    final report = session.report;
    if (report == null) return;
    _reports.removeWhere((stored) => stored.id == report.id);
    _reports.insert(0, report);
  }
}
