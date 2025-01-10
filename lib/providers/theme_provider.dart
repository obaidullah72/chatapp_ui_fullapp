import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default is light theme
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Light Theme
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF6A1B9A),
      scaffoldBackgroundColor: Color(0xFFF8F8F8),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF6A1B9A),
      ),
      iconTheme: IconThemeData(color: Colors.black),
      textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    );
  }

  // Dark Theme
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF6A1B9A),
      scaffoldBackgroundColor: Color(0xFF212121),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF6A1B9A),
      ),
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    );
  }
}
