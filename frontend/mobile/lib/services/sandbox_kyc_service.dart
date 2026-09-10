import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result returned from Sandbox.co.in Live Central KYC Registry
class SandboxKycResult {
  final bool isValid;
  final String registeredName;
  final String documentNumber;
  final String status;
  final String category;
  final String message;

  const SandboxKycResult({
    required this.isValid,
    required this.registeredName,
    required this.documentNumber,
    required this.status,
    required this.category,
    required this.message,
  });

  factory SandboxKycResult.empty() => const SandboxKycResult(
        isValid: false,
        registeredName: '',
        documentNumber: '',
        status: 'UNVERIFIED',
        category: '',
        message: 'No record found',
      );
}

/// Sandbox.co.in Official Government KYC Registry Verification Service
class SandboxKycService {
  static final SandboxKycService _instance = SandboxKycService._internal();
  factory SandboxKycService() => _instance;
  SandboxKycService._internal();

  static String get apiKey =>
      utf8.decode(base64Decode('a2V5X2xpdmVfNjUwODRlOTU0YWRmNDlkYzk5Mjc5NDU4N2I2YzYwNDU='));
  static String get apiSecret =>
      utf8.decode(base64Decode('c2VjcmV0X2xpdmVfZmJmNjQwMWJhY2E5NDViYWFhMTFlNjg0MmVkOThjMzA='));

  static String get _baseUrl =>
      kIsWeb ? '/api/sandbox' : 'https://api.sandbox.co.in';

  static String get _authUrl => '$_baseUrl/authenticate';

  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Authenticates with Sandbox.co.in to obtain a live JWT bearer access token
  Future<String?> _getAccessToken() async {
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_authUrl),
            headers: {
              'x-api-key': apiKey,
              'x-api-secret': apiSecret,
              'x-api-version': '1.0',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final token = data['data']?['access_token'] ?? data['access_token'];
        if (token != null) {
          _cachedToken = token.toString();
          // Token is valid for 24 hours; cache for 23 hours
          _tokenExpiry = DateTime.now().add(const Duration(hours: 23));
          return _cachedToken;
        }
      } else {
        debugPrint('Sandbox Auth failed HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sandbox Auth error: $e');
    }
    return null;
  }

  /// Verifies a PAN number directly against the Income Tax Department registry
  Future<SandboxKycResult> verifyPan(String panNumber) async {
    final cleanPan = panNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleanPan.length != 10) return SandboxKycResult.empty();

    final token = await _getAccessToken();
    if (token == null) return SandboxKycResult.empty();

    final uri = Uri.parse(
        '$_baseUrl/pans/$cleanPan/verify?consent=Y&reason=KYC_Verification');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': token,
          'x-api-key': apiKey,
          'x-api-version': '1.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'];
        if (data != null && data is Map<String, dynamic>) {
          final fullName = (data['full_name'] ?? '').toString().trim().toUpperCase();
          final status = (data['status'] ?? '').toString().trim().toUpperCase();
          final category = (data['category'] ?? '').toString().trim();
          final isValid = status == 'VALID' || fullName.isNotEmpty;

          debugPrint('Sandbox KYC Success for $cleanPan: $fullName ($status)');
          return SandboxKycResult(
            isValid: isValid,
            registeredName: fullName,
            documentNumber: cleanPan,
            status: status,
            category: category,
            message: isValid
                ? 'Central ITD Database Verified • Registered Cardholder Matched'
                : 'PAN status: $status',
          );
        }
      } else {
        debugPrint('Sandbox PAN check HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sandbox PAN verify error: $e');
    }

    return SandboxKycResult.empty();
  }
}
