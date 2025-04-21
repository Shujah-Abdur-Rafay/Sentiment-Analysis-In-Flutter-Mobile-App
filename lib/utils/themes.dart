import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppThemes {
  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        background: Color(0xFFF8F9FA),
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: Color(0xFF303030),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF303030),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF303030),
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF303030),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF303030),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF303030),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF303030),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF505050),
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF505050),
          fontWeight: FontWeight.normal,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 24,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(
          color: Color(0xFFAAAAAA),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1F2B),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: Color(0xFF252A35),
        background: Color(0xFF1A1F2B),
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF252A35),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.tertiary),
        titleTextStyle: TextStyle(
          color: Color(0xFFECEFF5),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        color: const Color(0xFF252A35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF36394A),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252A35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF36394A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF36394A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.tertiary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFBBC3CD),
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          side: const BorderSide(color: AppColors.tertiary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFFECEFF5),
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFFECEFF5),
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFFECEFF5),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFDCE2EE),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFFDCE2EE),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFDCE2EE),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFBBC3CD),
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFBBC3CD),
          fontWeight: FontWeight.normal,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF36394A),
        thickness: 1,
        space: 24,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.tertiary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(
          color: AppColors.textSecondary.withOpacity(0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF252A35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF36394A),
            width: 1,
          ),
        ),
        elevation: 8,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF252A35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF36394A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Color(0xFFECEFF5),
          fontSize: 12,
        ),
      ),
    );
  }

  // Theme extensions
  static ThemeExtension<AppExtendedTheme> getExtendedTheme(bool isDark) {
    return isDark ? _darkExtendedTheme : _lightExtendedTheme;
  }

  static final _lightExtendedTheme = AppExtendedTheme(
    cardGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Color(0xFFF5F5F5)],
    ),
    subtleAccentColor: const Color(0xFFEFF3FF),
    cardBorderColor: const Color(0xFFE0E0E0),
    avatarBackgroundColor: const Color(0xFFF0F0F0),
    statusSuccessColor: const Color(0xFF22C55E),
    statusWarningColor: const Color(0xFFFACC15),
    statusInfoColor: const Color(0xFF3B82F6),
  );

  static final _darkExtendedTheme = AppExtendedTheme(
    cardGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF252A35), Color(0xFF1A1F2B)],
    ),
    subtleAccentColor: const Color(0xFF2A3142),
    cardBorderColor: const Color(0xFF36394A),
    avatarBackgroundColor: const Color(0xFF1A1F2B),
    statusSuccessColor: AppColors.success,
    statusWarningColor: AppColors.warning,
    statusInfoColor: AppColors.info,
  );
}

// Custom theme extension
class AppExtendedTheme extends ThemeExtension<AppExtendedTheme> {
  final Gradient cardGradient;
  final Color subtleAccentColor;
  final Color cardBorderColor;
  final Color avatarBackgroundColor;
  final Color statusSuccessColor;
  final Color statusWarningColor;
  final Color statusInfoColor;

  AppExtendedTheme({
    required this.cardGradient,
    required this.subtleAccentColor,
    required this.cardBorderColor,
    required this.avatarBackgroundColor,
    required this.statusSuccessColor,
    required this.statusWarningColor,
    required this.statusInfoColor,
  });

  @override
  ThemeExtension<AppExtendedTheme> copyWith({
    Gradient? cardGradient,
    Color? subtleAccentColor,
    Color? cardBorderColor,
    Color? avatarBackgroundColor,
    Color? statusSuccessColor,
    Color? statusWarningColor,
    Color? statusInfoColor,
  }) {
    return AppExtendedTheme(
      cardGradient: cardGradient ?? this.cardGradient,
      subtleAccentColor: subtleAccentColor ?? this.subtleAccentColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      avatarBackgroundColor:
          avatarBackgroundColor ?? this.avatarBackgroundColor,
      statusSuccessColor: statusSuccessColor ?? this.statusSuccessColor,
      statusWarningColor: statusWarningColor ?? this.statusWarningColor,
      statusInfoColor: statusInfoColor ?? this.statusInfoColor,
    );
  }

  @override
  ThemeExtension<AppExtendedTheme> lerp(
    covariant ThemeExtension<AppExtendedTheme>? other,
    double t,
  ) {
    if (other is! AppExtendedTheme) {
      return this;
    }

    return AppExtendedTheme(
      cardGradient: Gradient.lerp(cardGradient, other.cardGradient, t)!,
      subtleAccentColor:
          Color.lerp(subtleAccentColor, other.subtleAccentColor, t)!,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      avatarBackgroundColor:
          Color.lerp(avatarBackgroundColor, other.avatarBackgroundColor, t)!,
      statusSuccessColor:
          Color.lerp(statusSuccessColor, other.statusSuccessColor, t)!,
      statusWarningColor:
          Color.lerp(statusWarningColor, other.statusWarningColor, t)!,
      statusInfoColor: Color.lerp(statusInfoColor, other.statusInfoColor, t)!,
    );
  }
}
