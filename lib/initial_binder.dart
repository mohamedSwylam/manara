import 'package:get/get.dart';
import 'data/viewmodel/auth/reset_password_screen_controller.dart';
import 'data/viewmodel/auth/signin_screen_controller.dart';
import 'data/viewmodel/auth/signup_screen_controller.dart';
import 'data/viewmodel/auth/verify_email_screen_controller.dart';
import 'data/viewmodel/auth/verify_otp_screen_controller.dart';
import 'data/viewmodel/azkar_category_data_list_controller.dart';
import 'data/viewmodel/category_list_controller.dart';
import 'data/viewmodel/dua_category_data_list_controller.dart';
import 'data/viewmodel/edit_profile_screen_controller.dart';
import 'data/viewmodel/event_prayer_category_data_list_controller.dart';
import 'data/viewmodel/full_surah_details_controller.dart';
import 'data/viewmodel/hadith_category_data_list_controller.dart';
import 'data/viewmodel/onboarding_screen_controller.dart';

import 'data/viewmodel/theme_controller.dart';


class InitialBinder extends Bindings {
  @override
  void dependencies() {

    Get.put(OnboardingScreenController());
    Get.put(SignUpScreenController());
    Get.put(SignInScreenController());
    Get.put(VerifyEmailScreenController());
    Get.put(OtpVerificationController());
    Get.put(ResetPasswordScreenController());
    Get.put(CategoryListController());
    Get.put(HadithCategoryDataListController());
    Get.put(DuaCategoryDataListController());
    Get.put(AzkarCategoryDataListController());
    Get.put(EventPrayerCategoryDataListController());
    Get.put(FullSurahDetailsController());
    Get.put(EditProfileScreenController());
    Get.put(ThemeController());

    // LocalizationController will be initialized in LanguageDependency.init()
  }
}
