import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/allergen_classifier.dart';

class AIProcessingScreen extends StatefulWidget {
  final String text;

  const AIProcessingScreen(
      {super.key, required this.text}); // Constructor with required text

  @override
  AIProcessingScreenState createState() => AIProcessingScreenState();
}

class AIProcessingScreenState extends State<AIProcessingScreen> {
  bool _isProcessing = true;
  String _result = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _processText();
  }

  Future<void> _processText() async {
    try {
      // Call the Flask API
      final response = await http.post(
        Uri.parse('http://192.168.18.39:5050/check_allergens/'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': widget.text}),
      );

      if (response.statusCode == 200) {
        // Parse the response from the Flask API
        final analysisResult = jsonDecode(response.body);

        setState(() {
          _result = '''
        Final Decision: ${analysisResult['final_decision']}
        Model Prediction: ${analysisResult['model_prediction']}
        High-Risk Ingredients: ${analysisResult['high_risk_ingredients']}
        Potential Risks: ${analysisResult['potential_risks']}
      ''';
          _isProcessing = false;
        });
      } else {
        throw Exception('Failed to analyze text. Status code: ${response.statusCode}');
      }
    } catch (e) {
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'AI Analysis',
          style: AppTheme.headingStyle,
        ),
        backgroundColor: AppTheme.primaryColor, // App bar background color
        elevation: 0, // No shadow under the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
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
            ? Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the content vertically
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white), // Loading indicator color
                    ),
                    const SizedBox(
                        height: 24), // Space between the indicator and text
                    Text(
                      'Analyzing nutritional information...', // Loading message
                      style: AppTheme.subheadingStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
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
                        const SizedBox(
                            height: 16), // Space between icon and text
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .stretch, // Stretch the column to fill the width
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              16), // Padding inside the card
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
