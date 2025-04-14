import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

class ProfileScreen extends StatelessWidget {
  final bool isLoggedIn = false; // Replace with actual login state logic
  final String userName = 'John Doe'; // Replace with actual user data

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back icon
          onPressed: () {
            // Navigate back to Home if there's no previous screen
            if (GoRouter.of(context).canPop()) {
              context.pop(); // Pop the current screen if possible
            } else {
              context.go(AppRoutes.home); // Navigate to Home if nothing to pop
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoggedIn
            ? _buildLoggedInView(context) // Show profile info if logged in
            : _buildLoggedOutView(context), // Show login/signup options if not logged in
      ),
    );
  }

  // View for logged-in users
  Widget _buildLoggedInView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryLightColor,
          child: const Icon(
            Icons.person_rounded,
            size: 50,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: AppTheme.headingStyle,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            // Handle logout logic
            context.go(AppRoutes.login); // Navigate to Login screen
          },
          style: AppTheme.primaryButtonStyle,
          child: const Text('Logout'),
        ),
      ],
    );
  }

  // View for logged-out users
  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Welcome to NutriGuard!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Log in or sign up to access your profile and personalized features.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            context.go(AppRoutes.login); // Navigate to Login screen
          },
          style: AppTheme.primaryButtonStyle,
          child: const Text('Login'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            context.go(AppRoutes.signup); // Navigate to Sign Up screen
          },
          style: AppTheme.secondaryButtonStyle,
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}

final profileRoute = GoRoute(
  path: AppRoutes.profile,
  builder: (context, state) => const ProfileScreen(),
);