import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;

  ThemeData? get lightTheme => _lightTheme;
  ThemeData? get darkTheme => _darkTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}