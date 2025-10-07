import 'package:shared_preferences/shared_preferences.dart';

class LanguageCheckingController {
  static String? _setLang;

  static String? get setLang => _setLang;

  static Future<void> setLanguage(String lang) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('set_language', lang);
    _setLang = lang;
  }

  static Future<void> getLanguage() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _setLang = sharedPreferences.getString('set_language');
  }
}
