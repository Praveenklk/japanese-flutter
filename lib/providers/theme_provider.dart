import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// ThemeProvider - Manages dark/light theme state
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isLoading = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initialize theme from SharedPreferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  /// Set dark mode explicitly
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);
      notifyListeners();
    }
  }
}
