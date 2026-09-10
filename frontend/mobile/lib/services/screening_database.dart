import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/screening_session.dart';
import '../models/verification_result.dart';

class ScreeningDatabase {
  ScreeningDatabase._();

  static final instance = ScreeningDatabase._();
  static const _storageKey = 'shield_id_audit_history';
  final List<VerificationReport> _reports = [];

  Future<List<VerificationReport>> loadReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey);
      if (rawList != null && rawList.isNotEmpty) {
        _reports.clear();
        for (final item in rawList) {
          try {
            final json = jsonDecode(item) as Map<String, dynamic>;
            _reports.add(VerificationReport.fromJson(json));
          } catch (_) {}
        }
      }
    } catch (_) {}
    return List<VerificationReport>.from(_reports);
  }

  Future<void> saveReport(VerificationReport report) async {
    _reports.removeWhere((stored) => stored.id == report.id);
    _reports.insert(0, report);
    await _persist();
  }

  Future<void> saveSession(ScreeningSession session) async {
    final report = session.report;
    if (report == null) return;
    await saveReport(report);
  }

  Future<void> clearHistory() async {
    _reports.clear();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList =
          _reports.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (_) {}
  }
}
