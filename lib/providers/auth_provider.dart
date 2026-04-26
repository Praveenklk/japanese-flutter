import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String _userEmail = '';
  String _userName = '';
  String _userLevel = 'N5';
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String get userLevel => _userLevel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isLoggedIn || _isGuest;

  /// ================= INIT =================
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    _isGuest = prefs.getBool(AppConstants.keyIsGuest) ?? false;
    _userEmail = prefs.getString(AppConstants.keyUserEmail) ?? '';
    _userName = prefs.getString(AppConstants.keyUserName) ?? '';
    _userLevel = prefs.getString(AppConstants.keyUserLevel) ?? 'N5';

    notifyListeners();
  }

  /// ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.post("/auth/login", {
        "email": email,
        "password": password,
      });

      final token = response["access_token"];

      if (token != null) {
        // ✅ Save token
        await ApiService.setToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setBool(AppConstants.keyIsGuest, false);
        await prefs.setString(AppConstants.keyUserEmail, email);
        await prefs.setString(
          AppConstants.keyUserName,
          _getNameFromEmail(email),
        );

        _isLoggedIn = true;
        _isGuest = false;
        _userEmail = email;
        _userName = _getNameFromEmail(email);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = "Invalid login response";
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// ================= SIGNUP =================
  Future<bool> signup(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ApiService.post("/auth/register", {
        "email": email,
        "password": password,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setBool(AppConstants.keyIsGuest, false);
      await prefs.setString(AppConstants.keyUserEmail, email);
      await prefs.setString(AppConstants.keyUserName, name);

      _isLoggedIn = true;
      _isGuest = false;
      _userEmail = email;
      _userName = name;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// ================= GUEST =================
  Future<bool> guestLogin() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.setBool(AppConstants.keyIsGuest, true);
      await prefs.setString(AppConstants.keyUserName, 'Guest');

      _isLoggedIn = false;
      _isGuest = true;
      _userName = 'Guest';

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.setBool(AppConstants.keyIsGuest, false);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserName);

    await ApiService.clearToken(); // 🔥 important

    _isLoggedIn = false;
    _isGuest = false;
    _userEmail = '';
    _userName = '';

    notifyListeners();
  }

  /// ================= UPDATE LEVEL =================
  Future<void> updateLevel(String level) async {
    _userLevel = level;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserLevel, level);

    notifyListeners();
  }

  /// ================= CLEAR ERROR =================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// ================= HELPER =================
  String _getNameFromEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0].capitalize();
    }
    return email;
  }
}

/// String extension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}