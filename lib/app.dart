import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:manara/initial_binder.dart';
import 'package:manara/presentation/views/splash_screen.dart';

import 'constants/localization/app_constants.dart';
import 'constants/localization/messages.dart';
import 'constants/theme_manager.dart';
import 'data/viewmodel/language_controller.dart';
import 'data/viewmodel/theme_controller.dart';
import 'data/services/location_service.dart';

class ThemeWrapper extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  
  const ThemeWrapper({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    // Check if ThemeController is available
    try {
      final themeController = Get.find<ThemeController>();
      return GetBuilder<ThemeController>(
        builder: (controller) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            data: controller.themeData,
            child: GetMaterialApp(
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: const [
                Locale('en', 'USA'),
                Locale('ar', 'SA'),
              ],
              debugShowCheckedModeBanner: false,
              title: 'Manara',
              theme: controller.themeData,
              locale: Get.find<LocalizationController>().locale,
              translations: Messages(languages: languages),
              fallbackLocale: Locale(
                AppConstants.languages[0].languageCode,
                AppConstants.languages[0].countryCode,
              ),
              initialBinding: InitialBinder(),
              home: const SplashScreen(),
            ),
          );
        },
      );
    } catch (e) {
      // ThemeController not found, use fallback theme
      return GetMaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('en', 'USA'),
          Locale('ar', 'SA'),
        ],
        debugShowCheckedModeBanner: false,
        title: 'Manara',
        theme: ThemeManager.getAppTheme(),
        locale: Get.find<LocalizationController>().locale,
        translations: Messages(languages: languages),
        fallbackLocale: Locale(
          AppConstants.languages[0].languageCode,
          AppConstants.languages[0].countryCode,
        ),
        initialBinding: InitialBinder(),
        home: const SplashScreen(),
      );
    }
  }
}

class JazakAllah extends StatelessWidget {
  const JazakAllah({super.key, required this.languages});

  final Map<String, Map<String, String>> languages;

  @override
  Widget build(BuildContext context) {
    /// Lock the orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (context) => LocationService(),
          child: ThemeWrapper(languages: languages),
        );
      },
    );
  }
}
