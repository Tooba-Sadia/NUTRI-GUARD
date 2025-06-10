// filepath: c:\Users\k\Documents\GitHub\NUTRI-GUARD\myapp\lib\services\user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import '../services/user_service.dart';
import '../screens/profile_screen.dart'; // Import ProfileScreen here
import '../state/user_state.dart'; // Import UserState

// Service class for user-related API calls
class UserService {
  // Flask API base URL
  //static const String baseUrl = 'http://10.8.144.101:5000'; // Flask API URL
  static const String baseUrl = 'https://fd26-2407-d000-d-7b7f-516d-ab17-251d-b11b.ngrok-free.app';  // your PC IP here


  // Login API call
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); // API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return response as Map
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Signup API call
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup'); // API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name, // <-- use 'username' instead of 'name'
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body); // Return response as Map
    } else {
      throw Exception('Failed to signup: ${response.body}');
    }
  }
}

// Login screen widget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

// State for LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input
  bool _isLoading = false; // Loading state

  // Function to handle login logic
  Future<void> _login() async {
    // Check if fields are empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Call login API
      final response = await UserService.login(
        _emailController.text,
        _passwordController.text,
      );
      print('Login response: $response');
      if (response['status'] == 'success') {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        // Navigate to profile screen and pass username
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              username: response['user']['username'],
              isLoggedIn: true,
              userId: int.parse(response['user']['id'].toString()), // <-- add this if needed
            ),
          ),
        );

        // Update user state using Provider
        Provider.of<UserState>(context, listen: false).login(
          response['user']['username'],
          int.parse(response['user']['id'].toString()),
          response['user']['allergens'] == null ? [] : List<String>.from(jsonDecode(response['user']['allergens'])),
        );
      } else {
        // Show error message from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      // Show error if login fails
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'), // App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email input field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            // Password input field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Show loading indicator or login button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}