import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'web_ocr_interface.dart';

@JS('toggleWebTorch')
external JSPromise<JSBoolean> _toggleWebTorch(JSBoolean enable);

@JS('performWebOCR')
external JSPromise<JSString> _performWebOCR(JSString imageDataUrl);

WebOcrPlatform getWebOcrPlatform() => WebOcrWeb();

class WebOcrWeb implements WebOcrPlatform {
  @override
  Future<bool> toggleTorch(bool enable) async {
    try {
      final res = await _toggleWebTorch(enable.toJS).toDart;
      return res.toDart;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> recognizeTextFromBytes(Uint8List imageBytes) async {
    try {
      final base64Str = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final res = await _performWebOCR(base64Str.toJS).toDart;
      return res.toDart;
    } catch (e) {
      return '';
    }
  }
}
