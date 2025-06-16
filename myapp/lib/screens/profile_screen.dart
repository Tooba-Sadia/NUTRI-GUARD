import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/user_state.dart';
import '../theme/app_theme.dart';
import '../routes/app_router.dart';

class ProfileScreen extends StatelessWidget {
  final String? username;
  final bool isLoggedIn;
  final int? userId;

  const ProfileScreen({super.key, this.username, this.isLoggedIn = false, this.userId});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                userState.isLoggedIn && userState.username != null
                    ? userState.username!
                    : 'Not logged in',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userState.isLoggedIn
            ? _buildLoggedInView(context, userState.username)
            : _buildLoggedOutView(context),
      ),
    );
  }

  // View for logged-in users
  Widget _buildLoggedInView(BuildContext context, String? username) {
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
          username ?? 'Guest',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
                Provider.of<UserState>(context, listen: false).logout();

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

