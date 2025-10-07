import 'package:get/get.dart';

extension SurahNameExtension on Translations {
  String getSurahName(int surahNumber) {
    try {
      // Get current locale translations
      final currentLang = Get.locale?.languageCode ?? 'en';
      final translations = keys[currentLang] ?? keys['en'];
      
      // Access nested surah_names
      final surahNames = translations?['surah_names'] as Map<String, dynamic>?;
      
      return surahNames?[surahNumber.toString()] ?? 'Surah $surahNumber';
    } catch (e) {
      return 'Surah $surahNumber';
    }
  }
}