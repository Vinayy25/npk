import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Define light theme
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF2E7D32), // AppColors.primary
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF00ACC1),
        tertiary: Color(0xFF1E88E5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
      ),
      useMaterial3: true,
    );
  }

  // Define dark theme
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF81C784), // Lighter green for dark mode
      scaffoldBackgroundColor: Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF81C784),
        secondary: Color(0xFF4DD0E1),
        tertiary: Color(0xFF64B5F6),
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E),
      ),
      useMaterial3: true,
    );
  }
}