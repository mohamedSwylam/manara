import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/language_model.dart';
import '../../data/viewmodel/language_controller.dart';
import 'app_constants.dart';

class LanguageDependency {
  LanguageDependency._();

  static Future<Map<String, Map<String, String>>> init() async {
    final sharedPreference = await SharedPreferences.getInstance();
    Get.put(sharedPreference);
    Get.put(LocalizationController(sharedPreferences: sharedPreference));

    Map<String, Map<String, String>> languages = {};
    for (LanguageModel languageModel in AppConstants.languages) {
      String jsonStringValues = await rootBundle
          .loadString('assets/locales/${languageModel.languageCode}.json');
      Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

      Map<String, String> _json = {};
      mappedJson.forEach((key, value) {
        _json[key] = value.toString();
      });

      languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
          _json;
    }
    return languages;
  }
}
