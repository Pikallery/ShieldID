import 'dart:typed_data';
import 'web_ocr_interface.dart';

WebOcrPlatform getWebOcrPlatform() => WebOcrStub();

class WebOcrStub implements WebOcrPlatform {
  @override
  Future<bool> toggleTorch(bool enable) async => false;

  @override
  Future<String> recognizeTextFromBytes(Uint8List imageBytes) async => '';
}
