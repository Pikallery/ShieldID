import 'dart:typed_data';
import 'web_ocr/web_ocr_interface.dart';
import 'web_ocr/web_ocr_stub.dart'
    if (dart.library.html) 'web_ocr/web_ocr_web.dart';

class WebOcrService {
  static final WebOcrService _instance = WebOcrService._internal();
  factory WebOcrService() => _instance;
  WebOcrService._internal();

  final WebOcrPlatform _platform = getWebOcrPlatform();

  /// Toggles device flashlight / torch via browser mediaStream tracks
  Future<bool> toggleTorch(bool enable) => _platform.toggleTorch(enable);

  /// Runs client-side browser OCR directly on image bytes using Web Tesseract worker
  Future<String> recognizeTextFromBytes(Uint8List imageBytes) =>
      _platform.recognizeTextFromBytes(imageBytes);
}
