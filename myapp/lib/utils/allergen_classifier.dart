import 'package:tflite_flutter/tflite_flutter.dart';

class AllergenClassifier {
  late Interpreter _interpreter;

  /// Loads the TFLite model from the assets folder
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('bert.tflite');
      print('✅ TFLite model loaded successfully!');
    } catch (e) {
      print('❌ Failed to load TFLite model: $e');
    }
  }

  /// Preprocesses the input text
  /// This example converts the string to normalized ASCII codes (0.0 - 1.0)
  List<double> preprocess(String inputText) {
    // Convert string to ASCII codes and normalize to 0-1
    return inputText
        .codeUnits
        .map((unit) => unit / 255.0)
        .toList()
        .take(100) // Optional: trim to first 100 tokens
        .toList();
  }

  /// Runs inference on the input text and returns predicted label
  String predict(String inputText) {
    // Preprocess input
    List<double> processedInput = preprocess(inputText);

    // Reshape input: model expects [1, inputLength]
    var inputTensor = [processedInput];

    // Prepare output buffer (adjust shape depending on your model output)
    var output = List.filled(2, 0.0).reshape([1, 2]);

    // Run the model
    _interpreter.run(inputTensor, output);

    // Get predicted class (e.g., index of highest value)
    int predictedIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    // Return label based on index
    return predictedIndex == 0 ? "Non-Allergen" : "Allergen";
  }
}