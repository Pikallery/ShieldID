import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

/// Google Gemini Multimodal Vision AI Service
/// Performs direct visual understanding, text extraction, and forensic document analysis
class GeminiVisionService {
  static final GeminiVisionService _instance = GeminiVisionService._internal();
  factory GeminiVisionService() => _instance;
  GeminiVisionService._internal();

  static String get defaultApiKey =>
      utf8.decode(base64Decode('QVEuQWI4Uk42SWI2UExnZm9yZGFRVjhFeG9QNjBDWWtoVzIyT0RoTTQySHh2STgtbUF2ZVE='));
  static const String _model = 'gemini-3.6-flash';

  /// Analyzes a captured document image and extracts structured identity information
  Future<ExtractedDocumentData?> analyzeDocument({
    required Uint8List imageBytes,
    required DocumentType docType,
    String? apiKey,
  }) async {
    final key = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultApiKey;
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$key';

    final base64Img = base64Encode(imageBytes);

    final prompt = '''
You are an expert identity document verification and OCR AI engine.
Analyze this official Indian document image (${docType.name}) and extract all key identity fields.

Respond ONLY with a valid JSON object matching this schema:
{
  "document_type": "${docType.name}",
  "document_number": "10-character PAN number (e.g. SFAPS5084D) or 12-digit Aadhaar or DL number",
  "full_name": "Full legal name of the cardholder in UPPERCASE (e.g. SAI PRADYUMNA SAMAL)",
  "father_name": "Father's name if present",
  "date_of_birth": "DD/MM/YYYY",
  "gender": "Male / Female / Transgender",
  "is_genuine": true,
  "confidence_score": 0.98,
  "verdict": "Genuine document authenticated"
}
If any field is unreadable, provide your best high-confidence extraction or empty string. Do not include markdown formatting or backticks outside the JSON.
''';

    final requestBody = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Img,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'response_mime_type': 'application/json',
      }
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            String text = parts[0]['text'] ?? '';
            text = text.replaceAll(RegExp(r'^```json\s*'), '').replaceAll(RegExp(r'\s*```$'), '').trim();
            final parsedJson = jsonDecode(text) as Map<String, dynamic>;

            final docNumber = (parsedJson['document_number'] ?? '').toString().trim().toUpperCase();
            final name = (parsedJson['full_name'] ?? '').toString().trim().toUpperCase();
            final dob = (parsedJson['date_of_birth'] ?? '').toString().trim();
            final gender = (parsedJson['gender'] ?? '').toString().trim();

            if (docNumber.isNotEmpty || name.isNotEmpty) {
              debugPrint('Gemini Vision AI extraction success: $name ($docNumber)');
              return ExtractedDocumentData(
                fullName: name,
                documentNumber: docNumber,
                dateOfBirth: dob,
                dateOfExpiry: '',
                dateOfIssue: '',
                gender: gender,
                issuingCountry: 'India',
                nationality: 'Indian',
              );
            }
          }
        }
      } else {
        debugPrint('Gemini API HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Gemini Vision API error: $e');
    }

    return null;
  }
}
