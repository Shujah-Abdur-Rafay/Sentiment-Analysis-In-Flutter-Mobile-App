import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/themes.dart';
import '../utils/colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  SharedPreferences? _prefs;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  // Extended theme getter
  ThemeExtension<AppExtendedTheme> get extendedTheme =>
      AppThemes.getExtendedTheme(_isDarkMode);

  // Get accent color based on current theme
  Color get accentColor => _isDarkMode ? AppColors.tertiary : AppColors.primary;

  // Get current text highlight color
  Color get textHighlightColor =>
      _isDarkMode ? AppColors.textHighlight : AppColors.primary;

  // Get professional gradient for UI elements
  List<Color> get accentGradient =>
      _isDarkMode ? AppColors.blueGradient : AppColors.elegantGradient;

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs?.getBool('isDarkMode');
    if (isDark != null) {
      _isDarkMode = isDark;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      // Update status bar color based on theme
      _updateStatusBarColor();
      notifyListeners();
    } else {
      // Default to light mode for professional feel
      _isDarkMode = false;
      _themeMode = ThemeMode.light;
      await _saveTheme();
      _updateStatusBarColor();
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    await _prefs?.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
    _updateStatusBarColor();
    notifyListeners();
  }

  // Update status bar color to match theme
  void _updateStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          _isDarkMode ? AppColors.background : Colors.white,
      systemNavigationBarIconBrightness:
          _isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  // Get a themed shadow for elevated elements
  List<BoxShadow> get themedShadow {
    return [
      if (_isDarkMode) ...[
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ] else ...[
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ],
    ];
  }

  // Animation curve for theme transitions
  Curve get themeCurve => Curves.easeOutQuart;

  // Duration for theme transitions
  Duration get themeDuration => const Duration(milliseconds: 400);

  // Get border for elegant elements
  Border get elegantBorder {
    return Border.all(
      color: _isDarkMode
          ? AppColors.surfaceLight.withOpacity(0.2)
          : AppColors.surfaceDark.withOpacity(0.5),
      width: 1,
    );
  }

  // Get decoration for elegant cards
  BoxDecoration getElegantCardDecoration({
    BorderRadius? borderRadius,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: _isDarkMode ? AppColors.surface : Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: elegantBorder,
      boxShadow: withShadow ? themedShadow : null,
    );
  }

  // Get button style with elegant design
  ButtonStyle getElegantButtonStyle({
    bool isOutlined = false,
    EdgeInsetsGeometry? padding,
  }) {
    if (isOutlined) {
      return OutlinedButton.styleFrom(
        foregroundColor: _isDarkMode ? AppColors.tertiary : AppColors.primary,
        side: BorderSide(
          color: _isDarkMode ? AppColors.tertiary : AppColors.primary,
          width: 1.5,
        ),
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      return ElevatedButton.styleFrom(
        backgroundColor: _isDarkMode ? AppColors.tertiary : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: (_isDarkMode ? AppColors.tertiary : AppColors.primary)
            .withOpacity(0.3),
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
  }
}
