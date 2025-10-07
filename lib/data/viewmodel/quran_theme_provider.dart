import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranThemeProvider extends GetxController {
  static QuranThemeProvider get to => Get.find();
  
  final RxInt selectedThemeIndex = 0.obs;
  final RxDouble quranFontSize = 22.0.obs;
  final RxDouble tafsirFontSize = 19.0.obs;
  final RxBool tajweedRules = true.obs;
  final RxBool vibrationOnNewPage = true.obs;

  final List<Map<String, dynamic>> themes = [
    {
      'name': 'Beige', 
      'bgColor': const Color(0xFFF5F5DC), 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA6A7805A), 
      'selected': true
    },
    {
      'name': 'White', 
      'bgColor': Colors.white, 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA6000000), 
      'selected': false
    },
    {
      'name': 'Dark', 
      'bgColor': Colors.black, 
      'textColor': Colors.white, 
      'titleColor': const Color(0xFFA7805A), 
      'selected': false
    },
    {
      'name': 'Green', 
      'bgColor': const Color(0xFFE8F5E8), 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA65AA774), 
      'selected': false
    },
    {
      'name': 'Warm', 
      'bgColor': const Color(0xFFF7F4E7), 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA6A7805A), 
      'selected': false
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadThemeSettings();
  }

  Future<void> loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      selectedThemeIndex.value = prefs.getInt('quran_theme_index') ?? 0;
      quranFontSize.value = prefs.getDouble('quran_font_size') ?? 22.0;
      tafsirFontSize.value = prefs.getDouble('tafsir_font_size') ?? 19.0;
      tajweedRules.value = prefs.getBool('tajweed_rules') ?? true;
      vibrationOnNewPage.value = prefs.getBool('vibration_on_new_page') ?? true;
    } catch (e) {
      print('Error loading theme settings: $e');
    }
  }

  Future<void> saveThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quran_theme_index', selectedThemeIndex.value);
      await prefs.setDouble('quran_font_size', quranFontSize.value);
      await prefs.setDouble('tafsir_font_size', tafsirFontSize.value);
      await prefs.setBool('tajweed_rules', tajweedRules.value);
      await prefs.setBool('vibration_on_new_page', vibrationOnNewPage.value);
    } catch (e) {
      print('Error saving theme settings: $e');
    }
  }

  void setThemeIndex(int index) {
    print('Setting theme index to: $index');
    selectedThemeIndex.value = index;
    update(); // Force UI update
    saveThemeSettings();
  }

  void setQuranFontSize(double size) {
    print('Setting Quran font size to: $size');
    quranFontSize.value = size;
    update(); // Force UI update
    saveThemeSettings();
  }

  void setTafsirFontSize(double size) {
    print('Setting Tafsir font size to: $size');
    tafsirFontSize.value = size;
    update(); // Force UI update
    saveThemeSettings();
  }

  void setTajweedRules(bool value) {
    print('Setting Tajweed rules to: $value');
    tajweedRules.value = value;
    update(); // Force UI update
    saveThemeSettings();
  }

  void setVibrationOnNewPage(bool value) {
    print('Setting vibration on new page to: $value');
    vibrationOnNewPage.value = value;
    update(); // Force UI update
    saveThemeSettings();
  }

  Map<String, dynamic> get currentTheme => themes[selectedThemeIndex.value];
  
  Color get backgroundColor => currentTheme['bgColor'];
  Color get textColor => currentTheme['textColor'];
  Color get titleColor => currentTheme['titleColor'];
  String get themeName => currentTheme['name'];
}
