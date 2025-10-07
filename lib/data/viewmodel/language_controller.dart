import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../../constants/localization/app_constants.dart';
import '../../data/models/language_model.dart';

class LocalizationController extends GetxController {
  final SharedPreferences sharedPreferences;

  LocalizationController({required this.sharedPreferences}) {
    loadCurrentLanguage();
  }

  Locale _locale = Locale(AppConstants.languages[0].languageCode,
      AppConstants.languages[0].countryCode);

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;
  List<LanguageModel> _languages = [];

  Locale get locale => _locale;

  List<LanguageModel> get languages => _languages;

  void loadCurrentLanguage() {
    // First check if user has manually selected a language
    final savedLanguageCode = sharedPreferences.getString(AppConstants.languageCode);
    final savedCountryCode = sharedPreferences.getString(AppConstants.countryCode);
    
    if (savedLanguageCode != null && savedCountryCode != null) {
      // User has manually selected a language, use it
      _locale = Locale(savedLanguageCode, savedCountryCode);
      print('📱 Using saved language preference: $savedLanguageCode');
    } else {
      // No saved preference, check device language
      final deviceLocale = ui.window.locale;
      final deviceLanguageCode = deviceLocale.languageCode;
      
      // Check if device language is supported
      final supportedLanguage = AppConstants.languages.firstWhere(
        (lang) => lang.languageCode == deviceLanguageCode,
        orElse: () => AppConstants.languages[0], // Default to English if not supported
      );
      
      _locale = Locale(supportedLanguage.languageCode, supportedLanguage.countryCode);
      print('📱 Using device language: $deviceLanguageCode (supported: ${supportedLanguage.languageCode})');
    }

    // Find the index of the selected language
    for (int index = 0; index < AppConstants.languages.length; index++) {
      if (AppConstants.languages[index].languageCode == _locale.languageCode) {
        _selectedIndex = index;
        break;
      }
    }
    
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
    print('✅ Language loaded: ${_locale.languageCode}');
  }

  void setLanguage(Locale locale) {
    Get.updateLocale(locale);
    _locale = locale;
    saveLanguage(_locale);
    print(_locale);
    update();
    print(_locale);
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void saveLanguage(Locale locale) async {
    sharedPreferences.setString(
        AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.countryCode, locale.countryCode!);
  }
}
