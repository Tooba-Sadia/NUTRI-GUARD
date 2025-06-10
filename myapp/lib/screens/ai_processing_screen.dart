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
  String _result = ''; // Stores the result from the API
  String? _error; // Stores any error message

  @override
  void initState() {
    super.initState();
    _processText(); // Start processing when the screen is initialized
  }

  // Function to call the Flask API and process the text
  Future<void> _processText() async {
    try {
      // Call the Flask API with the input text
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': widget.text}),
      );

      if (response.statusCode == 200) {
        // Parse the response from the Flask API
        final analysisResult = jsonDecode(response.body);

        setState(() {
          // Format the result string for display
          _result = '''
        Final Decision: ${analysisResult['final_decision']}
        Model Prediction: ${analysisResult['model_prediction']}
        High-Risk Ingredients: ${analysisResult['high_risk_ingredients']}
        Potential Risks: ${analysisResult['potential_risks']}
      ''';
          _isProcessing = false; // Processing complete
        });
      } else {
        // Handle non-200 responses
        throw Exception('Failed to analyze text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors and update the UI
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Set background color
      appBar: AppBar(
        title: const Text(
          'AI Analysis',
          style: AppTheme.headingStyle,
        ),
        backgroundColor: AppTheme.primaryColor, // App bar background color
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
                        Container(
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
                        ),
                        const SizedBox(height: 24),
                        // Card showing the AI analysis result
                        Container(
                          padding: const EdgeInsets.all(16),
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
                                'AI Analysis',
                                style: AppTheme.subheadingStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _result,
                                style: AppTheme.bodyStyle,
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
