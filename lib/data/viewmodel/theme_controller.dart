import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme_manager.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  final _themeData = ThemeManager.getAppTheme().obs;
  ThemeData get themeData => _themeData.value;
  
  static const String _themeKey = 'is_dark_mode';
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _isDarkMode.value = isDark;
      _updateTheme(isDark);
      // Update UI for GetBuilder
      update();
    } catch (e) {
      print('Error loading theme preference: $e');
      _isDarkMode.value = false;
      _updateTheme(false);
      // Update UI for GetBuilder
      update();
    }
  }
  
  Future<void> toggleTheme() async {
    try {
      final newMode = !_isDarkMode.value;
      _isDarkMode.value = newMode;
      _updateTheme(newMode);
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newMode);
      
      // Update system UI overlay style
      _updateSystemUIOverlay(newMode);
      
      // Update UI for GetBuilder
      update();
      
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }
  
  void _updateTheme(bool isDark) {
    _themeData.value = ThemeManager.getAppTheme(isDark: isDark);
  }
  
  void _updateSystemUIOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
  
  // Method to get current theme brightness
  Brightness get brightness => _isDarkMode.value ? Brightness.dark : Brightness.light;
  
  // Method to check if current theme is dark
  bool get isDark => _isDarkMode.value;
}
