import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manara/presentation/views/main_navigation.dart';
import '../../presentation/views/home/home_screen.dart';
import '../../presentation/views/onboarding_screen.dart';
import '../../presentation/views/menus/preferance/change_language_screen.dart';
import '../utility/token_manager.dart';
import 'navigation_controller.dart';
import 'language_controller.dart';
import '../../constants/localization/app_constants.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    goToNextScreen();
  }

  //Method for navigate next screen
  Future<void> goToNextScreen() async {
    await AuthController.getAccessToken();
    await AuthController.getExpireDateAndTime();
    await NavigationController.getOnboardingValue();
    await NavigationController.getLanguageValue();
    await Future.delayed(const Duration(seconds: 2));
    
    // Clear any existing onboarding/language preferences to ensure clean first launch
    await NavigationController.setLanguageValue(true);
    await NavigationController.setOnboardingValue(false);
    
    // Set English as the default language
    final localizationController = Get.find<LocalizationController>();
    localizationController.setLanguage(Locale(
      AppConstants.languages[0].languageCode, // 'en'
      AppConstants.languages[0].countryCode,  // 'US'
    ));
    localizationController.setSelectedIndex(0);
    
    // Always go to MainNavigation
    Get.offAll(() => MainNavigation());
  }
}
