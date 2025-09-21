import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _material3Key = 'material_3';
  static const String _colorThemeKey = 'color_theme';

  late SharedPreferences _prefs;

  bool _isDarkMode = false;
  bool _useMaterial3 = true;
  int _colorTheme = 0;

  bool get isDarkMode => _isDarkMode;
  bool get useMaterial3 => _useMaterial3;
  int get colorTheme => _colorTheme;

  Color get primaryColor {
    // Modern, soft teal/blue primary color matching the reference image
    return const Color(0xFF4DB6AC); // Soft teal
  }

  Color get secondaryColor {
    // Soft, muted green secondary color
    return const Color(0xFF81C784); // Light sage green
  }

  // Additional colors for the minimalist design palette
  Color get accentColor => const Color(0xFF66BB6A); // Fresh green accent
  Color get surfaceColor => _isDarkMode
      ? const Color(0xFF2D2D2D) // Dark surface
      : const Color(0xFFFAFBFF); // Light surface

  Color get cardColor => _isDarkMode
      ? const Color(0xFF3C3C3C) // Dark card
      : Colors.white; // Light card

  Color get textColor => _isDarkMode
      ? const Color(0xFFE0E0E0) // Light text on dark
      : const Color(0xFF2D2D2D); // Dark text on light

  Color get subtleTextColor => _isDarkMode
      ? const Color(0xFFB0B0B0) // Subtle text on dark
      : const Color(0xFF666666); // Subtle text on light

  // Gradient colors for modern card effects
  Color get gradientStartColor => _isDarkMode
      ? const Color(0xFF4DB6AC).withValues(alpha: 0.1)
      : const Color(0xFF4DB6AC).withValues(alpha: 0.05);

  Color get gradientEndColor => _isDarkMode
      ? const Color(0xFF81C784).withValues(alpha: 0.05)
      : const Color(0xFF81C784).withValues(alpha: 0.03);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    _useMaterial3 = _prefs.getBool(_material3Key) ?? true;
    _colorTheme = _prefs.getInt(_colorThemeKey) ?? 0;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setMaterial3(bool value) async {
    _useMaterial3 = value;
    await _prefs.setBool(_material3Key, value);
    notifyListeners();
  }

  Future<void> setColorTheme(int value) async {
    _colorTheme = value;
    await _prefs.setInt(_colorThemeKey, value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _isDarkMode = false;
    _useMaterial3 = true;
    _colorTheme = 0;

    await _prefs.setBool(_darkModeKey, false);
    await _prefs.setBool(_material3Key, true);
    await _prefs.setInt(_colorThemeKey, 0);

    notifyListeners();
  }
}

