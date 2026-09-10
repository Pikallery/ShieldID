import 'dart:typed_data';

abstract class WebOcrPlatform {
  Future<bool> toggleTorch(bool enable);
  Future<String> recognizeTextFromBytes(Uint8List imageBytes);
}
