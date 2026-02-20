import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black, // Text color
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF8B5CF6),
      surface: Colors.white,
      // background: Color(0xFFF5F5F5), // Deprecated in Flutter 3.22+, use surface
    ),
    useMaterial3: true,
  );

  // Calming Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: const Color(0xFF121212), // Deep, calming dark
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF818CF8), // Lighter Indigo
      secondary: Color(0xFFA78BFA), // Lighter Purple
      surface: Color(0xFF1E1E1E),
      // background: Color(0xFF121212),
    ),
    useMaterial3: true,
    // Ensure text is readable
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
      titleLarge: TextStyle(color: Colors.white),
    ),
  );
}
