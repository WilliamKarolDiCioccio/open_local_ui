import 'dart:typed_data';

class TTSService {
  TTSService._internal();

  static final TTSService _instance = TTSService._internal();

  factory TTSService() {
    return _instance;
  }

  Uint8List synthesyzeText(String text) {
    throw UnimplementedError();
  }
}
