import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryLightColor = Color(0xFF81C784);
  static const Color primaryDarkColor = Color(0xFF388E3C);

  // Accent colors
  static const Color accentColor = Color(0xFFFF9800);
  static const Color accentLightColor = Color(0xFFFFB74D);
  static const Color accentDarkColor = Color(0xFFF57C00);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFE0E0E0);

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Colors.white;

  // Error colors
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDarkColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentDarkColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Button styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: textLightColor,
    backgroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: primaryColor,
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: primaryColor),
    ),
    elevation: 0,
  );

  static final ButtonStyle accentButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: textLightColor,
    backgroundColor: accentColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  // Card styles
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Input decoration
  static final InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: surfaceColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
  );

  // App theme data
  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        primaryColorLight: primaryLightColor,
        primaryColorDark: primaryDarkColor,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          error: errorColor,
          surface: surfaceColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: textLightColor,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondaryColor,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        textTheme: const TextTheme(
          displayLarge: headingStyle,
          displayMedium: subheadingStyle,
          bodyLarge: bodyStyle,
          bodyMedium: bodyStyle,
          bodySmall: captionStyle,
        ),
      );

  static bool isDarkMode = false; // Track dark mode state

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  static ThemeData get lightTheme => ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        // Add other light theme properties here
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.grey[900],
        brightness: Brightness.dark,
        // Add other dark theme properties here
      );

  static void toggleTheme() {
    themeNotifier.value =
        themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  static void updateTheme(BuildContext context) {
    // Apply the theme dynamically (if using a state management solution, notify listeners here)
  }
}
