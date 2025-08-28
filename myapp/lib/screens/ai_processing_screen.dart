import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/allergen_classifier.dart';
import '../utils/config.dart';

// Stateful widget for AI Processing Screen
class AIProcessingScreen extends StatefulWidget {
  final String text; // Text to be analyzed

  const AIProcessingScreen({
    super.key,
    required this.text, // Constructor with required text
  });

  @override
  AIProcessingScreenState createState() => AIProcessingScreenState();
}

class AIProcessingScreenState extends State<AIProcessingScreen> {
  bool _isProcessing = true; // Indicates if processing is ongoing
  //String _result = ''; // Stores the result from the API
  String? _error; // Stores any error message
  String? detectedAllergen;
  String? potentialAllergens;
  String? confidence;
  String? finalDecision;
  String? highRiskIngredients;
  Map<String, dynamic> modelPrediction = {}; // Stores model predictions
  String formattedPredictions = ''; // Formatted string for model predictions
  String? _allergenResult; // Stores the allergen analysis result

  @override
  void initState() {
    super.initState();
    _processText(); // Start processing when the screen is initialized
  }

  // Function to call the Flask API and process the text
  // Future<void> _processText() async {
  //   setState(() {
  //     _isProcessing = true;
  //     _error = null;
  //     _allergenResult = null; // Clear previous result
  //   });

  //   print('Calling backend with text: ${widget.text}');

  //   try {
  //     final response = await http.post(
  //       Uri.parse('${AppConfig.baseUrl}/predict'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'text': widget.text}),
  //     );

  //     print('Response status: ${response.statusCode}');
  //     print('Response body of the allergen api: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final analysisResult = jsonDecode(response.body);

  //       print('Decoded analysisResult: $analysisResult');

  //       confidence = analysisResult['confidence'] ?? 'N/A';
  //       finalDecision = analysisResult['final_decision'] ?? 'N/A';
  //       highRiskIngredients = (analysisResult['high_risk_ingredients'] as List?)?.join(', ') ?? 'None';
  //       modelPrediction = (analysisResult['model_prediction'] as Map?)?.cast<String, dynamic>() ?? {};

  //       formattedPredictions = modelPrediction.entries
  //           .map((e) => '${e.key}: ${(e.value as num).toStringAsFixed(2)}')
  //           .join(', ');

  //       setState(() {
  //         detectedAllergen = analysisResult['detected_allergen'] ?? 'N/A';
  //         confidence = analysisResult['confidence'];
  //         finalDecision = analysisResult['final_decision'];
  //         highRiskIngredients = (analysisResult['high_risk_ingredients'] as List?)?.join(', ') ?? 'None';
  //         modelPrediction = (analysisResult['model_prediction'] as Map?)?.map(
  //           (key, value) => MapEntry(key.toString(), ((value as num) * 100)),
  //         ) ?? {};
  //         // Debug prints for processed values
  //         print('Final Decision: $finalDecision');
  //         print('Confidence: $confidence');
  //         print('High-Risk Ingredients: $highRiskIngredients');
  //         print('Model Prediction: $modelPrediction');
  //         _isProcessing = false; // Processing complete
  //       });
  //     } else {
  //       // Handle non-200 responses
  //       setState(() {
  //         _error = "Server error: ${response.statusCode}";
  //         _isProcessing = false;
  //       });
  //       print('Server error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle errors and update the UI
  //     if (mounted) {
  //       setState(() {
  //         _error = "Error: $e";
  //         _isProcessing = false;
  //       });
  //     }
  //     print('Exception caught: $e');
  //   }
  // }

Future<void> _processText() async {
  setState(() {
    _isProcessing = true;
    _error = null;
    _allergenResult = null; // Clear previous result
  });

  print('Processing text with Gemini: ${widget.text}');

  try {
    // Replace 'YOUR_GEMINI_API_KEY' with your actual API key
    const String geminiApiKey = 'AIzaSyDWsrBbCAhDW0jkqQjYGJgX0PbL9mWJodE';
    const String geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    // Create the prompt for Gemini
    final String prompt = '''
Analyze the following food ingredients text for allergens. Return a JSON response with this exact structure:

{
  "detected_allergen": "allergen name or N/A",
  "confidence": "percentage as string (e.g., '85%')",
  "final_decision": "Safe" or "Contains Allergens",
  "high_risk_ingredients": ["ingredient1", "ingredient2"] or [],
  "model_prediction": {
    "milk": 0.15,
    "eggs": 0.03,
    "peanuts": 0.92,
    "tree_nuts": 0.08,
    "soy": 0.05,
    "wheat": 0.12,
    "fish": 0.01,
    "shellfish": 0.02
  }
}

Instructions:
- Analyze for common allergens: milk, eggs, peanuts, tree nuts, soy, wheat, fish, shellfish
- Set confidence as a percentage string
- detected_allergen should be the highest risk allergen found or "N/A"
- final_decision should be "Contains Allergens" if any significant allergen is detected, otherwise "Safe"
- high_risk_ingredients should list ingredients that contain allergens
- model_prediction should show probability scores (0.0-1.0) for each allergen category
- Respond only with valid JSON, no additional text

Text to analyze: "${widget.text}"
''';

    final response = await http.post(
      Uri.parse('$geminiUrl?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{
            'text': prompt
          }]
        }],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 1,
          'topP': 1,
          'maxOutputTokens': 1000,
        }
      }),
    );

    print('Gemini Response status: ${response.statusCode}');
    print('Gemini Response body: ${response.body}');

    if (response.statusCode == 200) {
      final geminiResponse = jsonDecode(response.body);
      
      // Extract the generated text from Gemini response
      String generatedText = '';
      if (geminiResponse['candidates'] != null && 
          geminiResponse['candidates'].isNotEmpty &&
          geminiResponse['candidates'][0]['content'] != null &&
          geminiResponse['candidates'][0]['content']['parts'] != null &&
          geminiResponse['candidates'][0]['content']['parts'].isNotEmpty) {
        generatedText = geminiResponse['candidates'][0]['content']['parts'][0]['text'];
      }

      print('Generated text from Gemini: $generatedText');

      // Clean the response to extract JSON
      String jsonString = generatedText.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      // Parse the JSON response
      final analysisResult = jsonDecode(jsonString);

      print('Decoded analysisResult: $analysisResult');

      confidence = analysisResult['confidence'] ?? 'N/A';
      finalDecision = analysisResult['final_decision'] ?? 'N/A';
      highRiskIngredients = (analysisResult['high_risk_ingredients'] as List?)?.join(', ') ?? 'None';
      modelPrediction = (analysisResult['model_prediction'] as Map?)?.cast<String, dynamic>() ?? {};

      formattedPredictions = modelPrediction.entries
          .map((e) => '${e.key}: ${(e.value as num).toStringAsFixed(2)}')
          .join(', ');

      setState(() {
        detectedAllergen = analysisResult['detected_allergen'] ?? 'N/A';
        confidence = analysisResult['confidence'];
        finalDecision = analysisResult['final_decision'];
        highRiskIngredients = (analysisResult['high_risk_ingredients'] as List?)?.join(', ') ?? 'None';
        modelPrediction = (analysisResult['model_prediction'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), ((value as num) * 100)),
        ) ?? {};
        // Debug prints for processed values
        print('Final Decision: $finalDecision');
        print('Confidence: $confidence');
        print('High-Risk Ingredients: $highRiskIngredients');
        print('Model Prediction: $modelPrediction');
        _isProcessing = false; // Processing complete
      });
    } else {
      // Handle non-200 responses
      final errorResponse = jsonDecode(response.body);
      setState(() {
        _error = "Gemini API error: ${response.statusCode} - ${errorResponse['error']?['message'] ?? 'Unknown error'}";
        _isProcessing = false;
      });
      print('Gemini API error: ${response.statusCode}');
    }
  } catch (e) {
    // Handle errors and update the UI
    if (mounted) {
      setState(() {
        _error = "Error: $e";
        _isProcessing = false;
      });
    }
    print('Exception caught: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Set background color
      appBar: AppBar(
        
        backgroundColor: AppTheme.primaryColor,title: const Text(
          'AI Analysis',
          style: AppTheme.headingStyle,
        ), // App bar background color
        elevation: 0, // No shadow under the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home), // Navigate back to home
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: _isProcessing
            // Show loading indicator while processing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Loading indicator color
                    ),
                    const SizedBox(height: 24), // Space between indicator and text
                    Text(
                      'Analyzing nutritional information...', // Loading message
                      style: AppTheme.subheadingStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            // Show error message if any error occurs
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded, // Error icon
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16), // Space between icon and text
                        Text(
                          'Error analyzing text',
                          style: AppTheme.subheadingStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isProcessing = true; // Reset processing state
                              _error = null; // Clear error message
                            });
                            _processText(); // Retry processing
                          },
                          style: AppTheme.primaryButtonStyle,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                // Show the result if processing is complete and no error
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
                      children: [
                        // Card showing the original text
                       /* Container(
                          padding: const EdgeInsets.all(16), // Padding inside the card
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original Text',
                                style: AppTheme.subheadingStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.text,
                                style: AppTheme.bodyStyle,
                              ),
                            ],
                          ),
                        ),*/
                        const SizedBox(height: 24),
                        // Card showing the AI analysis result
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.analytics, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Analysis (Allergen)',
                                    style: AppTheme.subheadingStyle.copyWith(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Final Decision: $finalDecision',
                                style: AppTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Confidence: $confidence',
                                style: AppTheme.bodyStyle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'High-Risk Ingredients: $highRiskIngredients',
                                style: AppTheme.bodyStyle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Model Prediction:',
                                style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formattedPredictions,
                                style: AppTheme.bodyStyle,
                              ),
                              const SizedBox(height: 8),
                              // Display allergen result
                              Text(
                                _allergenResult ?? '',
                                style: AppTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Button to go back to home
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          style: AppTheme.accentButtonStyle,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
