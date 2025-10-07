import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utility/api_constants.dart';
import '../utility/secure_storage_manager.dart';

class FavoritesService {
  static final Dio _dio = Dio();
  static const String _favoritesKey = 'user_favorites';

  /// Toggle favorite status for a dua
  static Future<bool> toggleDuaFavorite(String duaId) async {
    try {
      log('🔄 Toggling favorite for dua: $duaId');
      
      // Check if user is logged in
      final isLoggedIn = await SecureStorageManager.isLoggedIn();
      if (!isLoggedIn) {
        log('❌ User not logged in');
        return false;
      }
      
      // Get auth token
      final token = await SecureStorageManager.getToken();
      if (token == null || token.isEmpty) {
        log('❌ No auth token found');
        return false;
      }

      // Try different request formats to see what works
      final requestData = {
        "favouritable_id": duaId,
        "favouritable_type": "Dua"
      };

      log('📤 Sending favorite toggle request: ${jsonEncode(requestData)}');

      // Make POST request
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.userFavourites}',
        data: requestData,
        options: Options(
          headers: ApiConstants.getAuthHeaders(token),
        ),
      );

      print('✅ Favorite toggle response: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      // Check if successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('✅ Favorite toggled successfully on server');
        
        // Also update local storage
        final isCurrentlyFavorited = await isInLocalFavorites(duaId);
        if (isCurrentlyFavorited) {
          await removeFromLocalFavorites(duaId);
          log('✅ Removed from local favorites');
        } else {
          await addToLocalFavorites(duaId);
          log('✅ Added to local favorites');
        }
        
        return true;
      } else {
        log('❌ Failed to toggle favorite: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error toggling favorite: $e');
      if (e is DioException) {
        log('📡 Dio error: ${e.response?.statusCode} - ${e.response?.data}');
        log('📡 Request URL: ${e.requestOptions.uri}');
        log('📡 Request method: ${e.requestOptions.method}');
        log('📡 Request headers: ${e.requestOptions.headers}');
        log('📡 Request data: ${e.requestOptions.data}');
      }
      return false;
    }
  }

  /// Check if a dua is favorited (using local storage since API doesn't support GET)
  static Future<bool> isDuaFavorited(String duaId) async {
    try {
      log('🔍 Checking if dua is favorited: $duaId');
      
      // Check if user is logged in
      final isLoggedIn = await SecureStorageManager.isLoggedIn();
      if (!isLoggedIn) {
        log('❌ User not logged in');
        return false;
      }
      
      // Check local storage for favorites
      final isFavorited = await isInLocalFavorites(duaId);
      log('📊 Dua $duaId favorited: $isFavorited (from local storage)');
      return isFavorited;
    } catch (e) {
      log('❌ Error checking favorite status: $e');
      return false;
    }
  }

  /// Get all favorited duas from local storage
  static Future<Set<String>> getLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        return Set<String>.from(favoritesList);
      }
      return <String>{};
    } catch (e) {
      log('❌ Error getting local favorites: $e');
      return <String>{};
    }
  }

  /// Save favorites to local storage
  static Future<void> saveLocalFavorites(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(favorites.toList());
      await prefs.setString(_favoritesKey, favoritesJson);
      log('✅ Saved ${favorites.length} favorites to local storage');
    } catch (e) {
      log('❌ Error saving local favorites: $e');
    }
  }

  /// Add a dua to local favorites
  static Future<void> addToLocalFavorites(String duaId) async {
    final favorites = await getLocalFavorites();
    favorites.add(duaId);
    await saveLocalFavorites(favorites);
  }

  /// Remove a dua from local favorites
  static Future<void> removeFromLocalFavorites(String duaId) async {
    final favorites = await getLocalFavorites();
    favorites.remove(duaId);
    await saveLocalFavorites(favorites);
  }

  /// Check if a dua is in local favorites
  static Future<bool> isInLocalFavorites(String duaId) async {
    final favorites = await getLocalFavorites();
    return favorites.contains(duaId);
  }
}
