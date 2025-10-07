import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys for secure storage
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _expireTimeKey = 'expire_time';

  // Token management
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      print('Error saving token to secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('Error deleting token from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    }
  }

  // User ID management
  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      print('Error saving user ID to secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    }
  }

  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading user ID from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    }
  }

  static Future<void> deleteUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      print('Error deleting user ID from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    }
  }

  // User data management (for storing user info)
  static Future<void> saveUserData(String userDataJson) async {
    try {
      await _storage.write(key: _userDataKey, value: userDataJson);
    } catch (e) {
      print('Error saving user data to secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, userDataJson);
    }
  }

  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      print('Error reading user data from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userDataKey);
    }
  }

  static Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      print('Error deleting user data from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
    }
  }

  // Expire time management
  static Future<void> saveExpireTime(String expireTime) async {
    try {
      await _storage.write(key: _expireTimeKey, value: expireTime);
    } catch (e) {
      print('Error saving expire time to secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_expireTimeKey, expireTime);
    }
  }

  static Future<String?> getExpireTime() async {
    try {
      return await _storage.read(key: _expireTimeKey);
    } catch (e) {
      print('Error reading expire time from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_expireTimeKey);
    }
  }

  static Future<void> deleteExpireTime() async {
    try {
      await _storage.delete(key: _expireTimeKey);
    } catch (e) {
      print('Error deleting expire time from secure storage: $e');
      // Fallback to shared preferences if secure storage fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_expireTimeKey);
    }
  }

  // Clear all authentication data
  static Future<void> clearAllAuthData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
    
    // Also clear from shared preferences as fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_expireTimeKey);
    } catch (e) {
      print('Error clearing shared preferences: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Save complete authentication data
  static Future<void> saveAuthData({
    required String token,
    required String userId,
    String? userDataJson,
    String? expireTime,
  }) async {
    try {
      await saveToken(token);
      await saveUserId(userId);
      if (userDataJson != null) {
        await saveUserData(userDataJson);
      }
      if (expireTime != null) {
        await saveExpireTime(expireTime);
      }
    } catch (e) {
      print('Error saving auth data: $e');
      // The individual methods already have fallback mechanisms
      rethrow;
    }
  }

  // Logout - clear all auth data
  static Future<void> logout() async {
    await clearAllAuthData();
  }
}
