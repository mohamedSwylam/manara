import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'fonts_weights.dart';

class ThemeManager {
  ThemeManager._();

  static ThemeData getAppTheme({bool isDark = false}) {
    return isDark ? _getDarkTheme() : _getLightTheme();
  }

  static ThemeData _getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.colorPrimary),
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.colorPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEBE64),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.0),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.colorBlackHighEmp,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppColors.colorBlackHighEmp,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontFamily: 'lobster',
          fontWeight: FontWeights.regular,
          color: AppColors.colorBlackHighEmp,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeights.regular,
          color: AppColors.colorBlackHighEmp,
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeights.regular,
          color: AppColors.colorBlackHighEmp,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.colorBlackHighEmp,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.colorPrimary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.colorPrimary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
    );
  }

  static ThemeData _getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEBE64),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.0),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.87),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.87),
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontFamily: 'lobster',
          fontWeight: FontWeights.regular,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeights.regular,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeights.regular,
          color: Colors.white,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.87),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.colorPrimary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.colorPrimary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.12),
      ),
      // Add more theme properties for dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: AppColors.colorPrimary,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: AppColors.colorPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: Colors.white.withOpacity(0.87),
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        modalBackgroundColor: const Color(0xFF1E1E1E),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF1E1E1E),
        textStyle: TextStyle(
          color: Colors.white.withOpacity(0.87),
        ),
      ),
    );
  }
}
