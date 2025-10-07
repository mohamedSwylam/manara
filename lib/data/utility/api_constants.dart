class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://manara.geeltech.space/api';
  
  // Auth endpoints
  static const String register = '/users/register';
  static const String login = '/users/login';
  static const String logout = '/users/logout';
  static const String findUser = '/users/find';
  static const String changePasswordReset = '/change-password';
  static const String forgotPassword = '/users/forgot-password';
  static const String resetPassword = '/users/reset-password';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/update-profile';
  static const String changePassword = '/users/change-password';
  
  // Dua endpoints
  static const String duaCategories = '/dua-categories/all';
  static const String duasByCategory = '/duas/category';
  
  // Azkar endpoints
  static const String azkarCategories = '/azkar-categories/all';
  static const String azkarTracking = '/azkar-tracking/category-progress';
  static const String azkarsByCategory = '/azkars/category';
  static const String azkarTrackingRepeat = '/azkar-tracking/repeat';
  
  // Favorites endpoints
  static const String userFavourites = '/user/favourites';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}
