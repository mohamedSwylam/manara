import 'dart:convert';
import 'secure_storage_manager.dart';
import '../models/auth/login_response_model.dart';
import '../services/auth_service.dart';

class AuthUtils {
  /// Get the current authentication token
  static Future<String?> getCurrentToken() async {
    return await SecureStorageManager.getToken();
  }

  /// Get the current user ID
  static Future<String?> getCurrentUserId() async {
    return await SecureStorageManager.getUserId();
  }

  /// Get the current user data as UserData object
  static Future<UserData?> getCurrentUserData() async {
    final userDataJson = await SecureStorageManager.getUserData();
    if (userDataJson != null) {
      try {
        final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
        return UserData.fromJson(userDataMap);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  /// Check if user is currently logged in
  static Future<bool> isUserLoggedIn() async {
    return await SecureStorageManager.isLoggedIn();
  }

  /// Get user's full name
  static Future<String?> getUserFullName() async {
    final userData = await getCurrentUserData();
    return userData?.fullName;
  }

  /// Get user's email
  static Future<String?> getUserEmail() async {
    final userData = await getCurrentUserData();
    return userData?.email;
  }

  /// Get user's total donation
  static Future<String?> getUserTotalDonation() async {
    final userData = await getCurrentUserData();
    return userData?.totalDonation;
  }

  /// Get user's profile image URL
  static Future<String?> getUserProfileImage() async {
    final userData = await getCurrentUserData();
    return userData?.fileUrl.originalUrl;
  }

  /// Get user's thumbnail image URL
  static Future<String?> getUserThumbnailImage() async {
    final userData = await getCurrentUserData();
    return userData?.fileUrl.thumbnailUrl;
  }

  /// Check if user has a profile image
  static Future<bool> hasProfileImage() async {
    final profileImage = await getUserProfileImage();
    return profileImage != null && profileImage.isNotEmpty;
  }

  /// Get authentication headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getCurrentToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Logout user and clear all data
  static Future<void> logout() async {
    await SecureStorageManager.logout();
  }

  /// Get user data as a map for easy access
  static Future<Map<String, dynamic>?> getUserDataMap() async {
    final userDataJson = await SecureStorageManager.getUserData();
    if (userDataJson != null) {
      try {
        return jsonDecode(userDataJson) as Map<String, dynamic>;
      } catch (e) {
        print('Error parsing user data map: $e');
        return null;
      }
    }
    return null;
  }

  /// Refresh user data from API
  static Future<UserData?> refreshUserData() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      final freshUserData = await AuthService.findUserById(userId);
      if (freshUserData != null) {
        // Update stored user data
        await SecureStorageManager.saveUserData(jsonEncode(freshUserData.toJson()));
      }
      return freshUserData;
    }
    return null;
  }

  /// Check if user exists and is valid
  static Future<bool> validateUserSession() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      final userData = await AuthService.findUserById(userId);
      return userData != null;
    }
    return false;
  }
}
