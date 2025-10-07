
import '../../data/models/language_model.dart';


class AppConstants {
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';

  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: "🇺🇸",
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: "🇸🇦",
      languageName: 'Arabic',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: "🇵🇰",
      languageName: 'Urdu',
      countryCode: 'PK',
      languageCode: 'ur',
    ),
    LanguageModel(
      imageUrl: "🇹🇷",
      languageName: 'Turkish',
      countryCode: 'TR',
      languageCode: 'tr',
    ),
    LanguageModel(
      imageUrl: "🇧🇩",
      languageName: 'Bangla',
      countryCode: 'BD',
      languageCode: 'bn',
    ),
    LanguageModel(
      imageUrl: "🇫🇷",
      languageName: 'French',
      countryCode: 'FR',
      languageCode: 'fr',
    ),
    LanguageModel(
      imageUrl: "🇮🇳",
      languageName: 'Hindi',
      countryCode: 'IN',
      languageCode: 'hi',
    ),

  ];
}
