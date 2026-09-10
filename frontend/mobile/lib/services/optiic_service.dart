import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';
import 'document_parser_service.dart';

/// Optiic AI Optical Recognition Service
/// Provides high-precision cloud text extraction from document images
class OptiicService {
  static final OptiicService _instance = OptiicService._internal();
  factory OptiicService() => _instance;
  OptiicService._internal();

  static const String defaultApiKey =
      '4N5exFpjVMo6Dod8fX4hdckaPPvWsxvrgMumY7zQkaX9';
  static const String _endpoint = 'https://api.optiic.dev/process';

  /// Extracts text from document image bytes using Optiic OCR API
  Future<String> recognizeText({
    required Uint8List imageBytes,
    String? apiKey,
  }) async {
    final key = (apiKey != null && apiKey.isNotEmpty) ? apiKey : defaultApiKey;
    if (key.isEmpty) return '';

    try {
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      final requestPayload = {
        'apiKey': key,
        'image': dataUrl,
        'mode': 'ocr',
      };

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestPayload),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final text = (data['text'] ?? '').toString().trim();
        debugPrint('Optiic OCR success: extracted ${text.length} characters');
        return text;
      } else {
        debugPrint('Optiic API returned HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Optiic OCR error: $e');
    }
    return '';
  }

  /// Extracts structured identity fields by running Optiic OCR followed by parser heuristics
  Future<ExtractedDocumentData?> extractDocument({
    required Uint8List imageBytes,
    required DocumentType docType,
    String? apiKey,
  }) async {
    final rawText = await recognizeText(imageBytes: imageBytes, apiKey: apiKey);
    if (rawText.isEmpty) return null;

    final parsed = DocumentParserService().parseRawDocumentText(
      docType: docType,
      rawText: rawText,
    );

    if (parsed.fullName.isNotEmpty || parsed.documentNumber.isNotEmpty) {
      return parsed;
    }
    return null;
  }
}
