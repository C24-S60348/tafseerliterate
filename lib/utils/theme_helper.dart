import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper {
  static const String _themeKey = 'selected_theme';

  // Get the current theme name from SharedPreferences
  static Future<String> getThemeName() async {
    final prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString(_themeKey) ?? 'Light';
    // Migrate old Malay theme names to English
    if (theme == 'Terang') {
      theme = 'Light';
      await prefs.setString(_themeKey, theme);
    } else if (theme == 'Gelap') {
      theme = 'Dark';
      await prefs.setString(_themeKey, theme);
    }
    return theme;
  }

  // Get ThemeData based on theme name
  static ThemeData getThemeData(String themeName) {
    switch (themeName) {
      case 'Dark':
      case 'Gelap': // Backward compatibility
        return _darkTheme();
      case 'Light':
      case 'Terang': // Backward compatibility
      default:
        return _lightTheme();
    }
  }

  // Light Theme
  static ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: Colors.white, dialogTheme: DialogThemeData(backgroundColor: Colors.white),
    );
  }

  // Dark Theme
  static ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1E1E1E), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1E1E1E)),
    );
  }

  // Get background color for content areas based on theme
  static Color getContentBackgroundColor(String themeName) {
    switch (themeName) {
      case 'Dark':
      case 'Gelap': // Backward compatibility
        return const Color(0xFF1E1E1E).withOpacity(0.9);
      case 'Light':
      case 'Terang': // Backward compatibility
      default:
        return Colors.white.withOpacity(0.9);
    }
  }

  // Get text color for content areas based on theme
  static Color getTextColor(String themeName) {
    switch (themeName) {
      case 'Dark':
      case 'Gelap': // Backward compatibility
        return Colors.white;
      case 'Light':
      case 'Terang': // Backward compatibility
      default:
        return Colors.black;
    }
  }
}

