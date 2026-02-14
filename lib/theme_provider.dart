import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool("isDarkMode") ?? false;
    notifyListeners(); // ✅ Notify UI to rebuild
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", isDark);
    notifyListeners(); // ✅ Notify UI to rebuild
  }
}
