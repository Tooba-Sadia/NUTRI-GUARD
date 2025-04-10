import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';

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
      // Set the Flask API URL
      final String apiUrl = 'http://${String.fromEnvironment('API_HOST', defaultValue: 'localhost')}:5050/check_allergens/';
      // Send a POST request to the Flask API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': widget.text}),
      );

      if (response.statusCode == 200) {
        // Parse the response
        final data = jsonDecode(response.body);
        setState(() {
          final allergens = data['allergens_found'] as List<dynamic>;
          final highRisk = data['high_risk_ingredients'] as List<dynamic>;
          final potentialRisks = data['potential_risks'] as List<dynamic>;

          var resultText = '';

          if (allergens.isEmpty) {
            resultText = 'No confirmed allergens found.\n\n';
          } else {
            resultText = 'Confirmed Allergens Found:\n• ${allergens.join('\n• ')}\n\n';
          }

          if (highRisk.isNotEmpty) {
            resultText += 'High Risk Ingredients:\n';
            for (var item in highRisk) {
              resultText += '• ${item['ingredient']}: ${item['allergens'].join(', ')}\n';
              resultText += '  Found in: ${item['found_in'].join(', ')}\n';
            }
            resultText += '\n';
          }

          if (potentialRisks.isNotEmpty) {
            resultText += 'Potential Risks:\n';
            for (var item in potentialRisks) {
              resultText += '• ${item['ingredient']} (similar to ${item['similar_to']})\n';
              resultText += '  May contain: ${item['allergens'].join(', ')}\n';
              resultText += '  Found in: ${item['found_in'].join(', ')}\n';
            }
          }

          _result = resultText;
          _isProcessing = false;
        });
      } else {
        throw Exception('Failed to connect to the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the API call
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
