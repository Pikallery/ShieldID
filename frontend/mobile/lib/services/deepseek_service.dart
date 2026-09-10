import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

/// DeepSeek AI Vision Extraction Service
/// Uses DeepSeek multimodal flash vision model for document field extraction
class DeepSeekService {
  static final DeepSeekService _instance = DeepSeekService._internal();
  factory DeepSeekService() => _instance;
  DeepSeekService._internal();

  static const String defaultApiKey = 'sk-a348641ef9284e4ea16ee81b13a6b22f';
  static const String _endpoint = 'https://api.deepseek.com/chat/completions';

  /// Extracts identity fields from document image bytes using DeepSeek Flash Vision API
  Future<ExtractedDocumentData?> extractDocumentWithVision({
    required Uint8List imageBytes,
    required DocumentType docType,
    String? apiKey,
  }) async {
    final key = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultApiKey;
    if (key.isEmpty) return null;

    try {
      final base64Image = base64Encode(imageBytes);
      final docTypeName = docType.shortName;

      final prompt = '''You are an expert Indian Government Document Extraction AI for ShieldID.
Examine this ${docType.displayName} ($docTypeName) image carefully and extract all printed information with 100% accuracy.
Return ONLY a valid, raw JSON object (no markdown, no ```json ``` fences) with these exact keys:
{
  "document_number": "exact document number, e.g. PAN or 12-digit Aadhaar",
  "full_name": "complete cardholder name as printed on the card",
  "date_of_birth": "DD/MM/YYYY or DD-MM-YYYY",
  "gender": "Male, Female, or Transgender",
  "father_name": "father name if present",
  "issuing_country": "India"
}
Important guidelines:
- For PAN cards, the PAN is 10 characters alphanumeric (e.g. SFAPS5084D).
- The full cardholder name must be the complete name (e.g. SAI PRADYUMNA SAMAL). Do not truncate words or initials.
- Extract the exact Date of Birth.
- If any field cannot be found, use an empty string "" for that field.''';

      final requestPayload = {
        'model': 'deepseek-flash',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'temperature': 0.1,
        'max_tokens': 500,
      };

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode(requestPayload),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']?['content']?.toString() ?? '';
          final cleaned = content
              .replaceAll(RegExp(r'^```(?:json)?', multiLine: true), '')
              .replaceAll(RegExp(r'```$', multiLine: true), '')
              .trim();

          final jsonStart = cleaned.indexOf('{');
          final jsonEnd = cleaned.lastIndexOf('}');
          if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
            final jsonStr = cleaned.substring(jsonStart, jsonEnd + 1);
            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

            final docNum = (parsed['document_number'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            final name =
                (parsed['full_name'] ?? '').toString().trim().toUpperCase();
            final dob = (parsed['date_of_birth'] ?? '').toString().trim();
            final gender = (parsed['gender'] ?? '').toString().trim();

            if (docNum.isNotEmpty || name.isNotEmpty) {
              return ExtractedDocumentData(
                documentNumber: docNum,
                fullName: name,
                dateOfBirth: dob,
                dateOfExpiry: '',
                dateOfIssue: '',
                gender: gender.isNotEmpty ? gender : 'Specified in Registry',
                issuingCountry: 'India',
                nationality: 'Indian',
              );
            }
          }
        }
      } else {
        debugPrint(
            'DeepSeek API returned HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('DeepSeek Vision extraction error: $e');
    }
    return null;
  }
}
