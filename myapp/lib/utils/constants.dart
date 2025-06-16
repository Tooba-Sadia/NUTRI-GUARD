import 'package:flutter/material.dart';

// Colors
const Color kPrimaryColor = Color.fromRGBO(115, 173, 128, 1);
const Color kSecondaryColor = Color.fromARGB(255, 169, 95, 184);
const Color kAccentColor = Color.fromARGB(255, 243, 206, 97);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kErrorColor = Color.fromARGB(255, 124, 224, 228);

// Gradients
const Color kGradientStart = Color(0xFF28a745);
const Color kGradientEnd = Color(0xFF81c784);

// Text Styles
const TextStyle kHeadingTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color(0xFF343a40),
);
const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Color(0xFF6c757d),
);
const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

// Padding & Margins
const double kDefaultPadding = 16.0;
const double kDefaultMargin = 16.0;
const double kDefaultBorderRadius = 15.0;

// Icon Paths
const String kLogoPath = 'assets/images/nutri_guard_logo.png';
const String kScanAnimationPath = 'assets/animations/scan_animation.json';

// Strings
const String kAppName = 'NutriGuard';
const String kWelcomeMessage = 'Welcome to NutriGuard!';
const String kErrorFetchingData = 'Failed to fetch data. Please try again.';

// API
const String kSpoonacularApiKey = '7bb378a3d04a4accb92f61c3a3ddd940';
const String kSpoonacularBaseUrl = 'https://api.spoonacular.com';
const String kRecipeRecommendationEndpoint = '/recipes/findByIngredients';

// Misc
const Duration kAnimationDuration = Duration(milliseconds: 300);
const int kDefaultSystolicBP = 120;
