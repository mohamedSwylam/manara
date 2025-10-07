import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoritedDuas = {};
  bool _isLoading = false;

  Set<String> get favoritedDuas => _favoritedDuas;
  bool get isLoading => _isLoading;

  /// Check if a dua is favorited
  bool isDuaFavorited(String duaId) {
    return _favoritedDuas.contains(duaId);
  }

  /// Toggle favorite status for a dua
  Future<bool> toggleDuaFavorite(String duaId) async {
    try {
      _isLoading = true;
      notifyListeners();

      log('🔄 Toggling favorite for dua: $duaId');
      
      final success = await FavoritesService.toggleDuaFavorite(duaId);
      
      if (success) {
        if (_favoritedDuas.contains(duaId)) {
          _favoritedDuas.remove(duaId);
          log('✅ Removed dua $duaId from favorites');
        } else {
          _favoritedDuas.add(duaId);
          log('✅ Added dua $duaId to favorites');
        }
      } else {
        log('❌ Failed to toggle favorite for dua: $duaId');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      log('❌ Error toggling favorite: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load favorite status for a list of duas
  Future<void> loadFavoriteStatus(List<String> duaIds) async {
    try {
      _isLoading = true;
      notifyListeners();

      log('🔄 Loading favorite status for ${duaIds.length} duas');
      
      for (final duaId in duaIds) {
        final isFavorited = await FavoritesService.isDuaFavorited(duaId);
        if (isFavorited) {
          _favoritedDuas.add(duaId);
        } else {
          _favoritedDuas.remove(duaId);
        }
      }

      log('✅ Loaded favorite status. Favorited duas: ${_favoritedDuas.length}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Error loading favorite status: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all favorites (for logout)
  void clearFavorites() {
    _favoritedDuas.clear();
    notifyListeners();
  }
}
