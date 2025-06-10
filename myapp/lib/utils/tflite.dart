import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteHelper {
  static late Interpreter _interpreter;
  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('mobilenet_v1_1.0_224.tflite');
      _isInitialized = true;
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  static Interpreter get interpreter {
    if (!_isInitialized) throw Exception("Model not initialized");
    return _interpreter;
  }
}