import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String? _username;
  bool _isLoggedIn = false;
  int? _userId;
  List<String> _allergens = [];
  List<String> get allergens => _allergens;

  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;

  void login(String username, int userId, List<String> allergens) {
    _username = username;
    _userId = userId;
    _allergens = allergens;
    _isLoggedIn = true;
    notifyListeners();
  }

  void setAllergens(List<String> allergens) {
    _allergens = allergens;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _userId = null;
    _allergens = [];
    _isLoggedIn = false;
    notifyListeners();
  }
}