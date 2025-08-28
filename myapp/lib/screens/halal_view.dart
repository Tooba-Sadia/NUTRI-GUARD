import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/routes/app_router.dart';
import 'dart:convert';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/config.dart';
import 'package:go_router/go_router.dart';

class HalalView extends StatefulWidget {
  final String text; // The recognized text

  const HalalView({super.key, required this.text});

  @override
  State<HalalView> createState() => _HalalViewState();
}

class _HalalViewState extends State<HalalView> {
  bool _isLoading = true;
  String? _error;
  String halalStatus = '';
  double? halalProbability;

  @override
  void initState() {
    super.initState();
    _checkHalalStatus();
  }

  Future<void> _checkHalalStatus() async {
    print("This is the text received in halal view:${widget.text}");
     final response = await http.post(
        Uri.parse('http://192.168.245.101:5050/halal_check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': widget.text}),
      );

      print("This is the response of the check halal status:${response.body}");
    try {
      debugPrint('Recognized text: ${widget.text}'); // Log the recognized text 
     

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          halalStatus = data['halal_status'] ?? 'Unknown';
          halalProbability = (data['halal_probability'] as num?)?.toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void updateProbability(double newProbability) {
    setState(() {
      halalProbability = newProbability;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Halal Status',
          style: AppTheme.headingStyle,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(), // Pops back to ImageViewPage
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
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
                                    Icon(Icons.verified, color: AppTheme.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Halal Status Check',
                                      style: AppTheme.subheadingStyle.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Status: $halalStatus',
                                  style: AppTheme.bodyStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: halalStatus == 'Halal'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Probability: ${halalProbability != null ? (halalProbability! * 100).toStringAsFixed(2) : 'N/A'}%',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.home),
                            label: const Text('Back to Home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: AppTheme.subheadingStyle,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              context.go(AppRoutes.home);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

// You can add more functionality here, like displaying the halal status
// or providing options to the user based on the received text.
