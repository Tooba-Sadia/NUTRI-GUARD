// filepath: c:\Users\k\Documents\GitHub\NUTRI-GUARD\myapp\lib\theme\theme_notifier.dart
import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}