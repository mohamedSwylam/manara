import 'package:shared_preferences/shared_preferences.dart';

class NavigationController {
  static bool? _isFirstTimeOpening;
  static bool? _isOnboardingComplete;
  static bool? _isLanguageSelectionComplete;

  static bool? get isFirstTimeOpening => _isFirstTimeOpening;

  static bool? get isOnboardingComplete => _isOnboardingComplete;

  static bool? get isLanguageSelectionComplete => _isLanguageSelectionComplete;

  static Future<void> setAppInstallValue(bool val) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool('is_first_time', val);
    _isFirstTimeOpening = val;
  }

  static Future<void> getAppInstallValue() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _isFirstTimeOpening = sharedPreferences.getBool('is_first_time');
  }

  static Future<void> setOnboardingValue(bool val) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool('is_onboarding_complete', val);
    _isOnboardingComplete = val;
  }

  static Future<void> getOnboardingValue() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _isOnboardingComplete = sharedPreferences.getBool('is_onboarding_complete');
  }

  static Future<void> setLanguageValue(bool val) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool('is_language_selection_complete', val);
    _isLanguageSelectionComplete = val;
  }

  static Future<void> getLanguageValue() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _isLanguageSelectionComplete =
        sharedPreferences.getBool('is_language_selection_complete');
  }
}
