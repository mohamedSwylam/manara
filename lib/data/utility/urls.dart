import 'package:flutter_dotenv/flutter_dotenv.dart';

class Urls {
  Urls._();

  // Get base URL with fallback
  static String get _baseUrl {
    try {
      final envUrl = dotenv.env['base_url'];
      if (envUrl != null && envUrl.isNotEmpty && !envUrl.contains('YOUR BASE URL HERE')) {
        return envUrl;
      }
    } catch (e) {
      print('⚠️ Error loading base_url from environment: $e');
    }
    
    // Fallback to a working API endpoint
    return 'https://manara.geeltech.space';
    // return 'https://api.quran.gading.dev';
  }

  static String userSignUp = '$_baseUrl/users/register';
  static String signIn = '$_baseUrl/users/login';
  static String sendOTP = '$_baseUrl/users/send-otp';
  static String verifyOTP = '$_baseUrl/users/validate-otp';
  static String resetPassword = '$_baseUrl/users/reset';
  static String getAllHadithApi = '$_baseUrl/hadiths/all';
  static String getAllDuaApi = '$_baseUrl/duas/all';
  static String getAllCurrency = '$_baseUrl/zakats/find';
  static String deleteAccount = '$_baseUrl/users/delete/';
  static String updateDonation = '$_baseUrl/users/update-donation/';
  static String liveLink = '$_baseUrl/link';

  static String getCategoryList(String categoryURL) =>
      '$_baseUrl/$categoryURL/all';
  static String getSurahList = 'https://api.quran.gading.dev/surah';

  static String getSurahFull(int surahNumber) => '$getSurahList/$surahNumber';

  static String getHadithCategoryData(String categoryName) =>
      '$_baseUrl/hadiths/category/$categoryName';

  static String getDuaCategoryData(String categoryName) =>
      '$_baseUrl/duas/category/$categoryName';

  static String getAzkarCategoryData(String categoryName) =>
      '$_baseUrl/azkars/category/$categoryName';

  static String getEventPrayerCategoryData(String categoryName) =>
      '$_baseUrl/event-prayers/category/$categoryName';

  static String fetchUserData = '$_baseUrl/users/find';
  static String fetchWallpapersData = '$_baseUrl/wallpapers/all';

  static String updateUserData(String id) => '$_baseUrl/users/update/$id';
}
