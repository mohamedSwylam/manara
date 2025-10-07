import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/favorites_service.dart';
import '../../utility/secure_storage_manager.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavoriteStatus>(_onLoadFavoriteStatus);
    on<ToggleDuaFavorite>(_onToggleDuaFavorite);
    on<ClearFavorites>(_onClearFavorites);
  }

  Future<void> _onLoadFavoriteStatus(
    LoadFavoriteStatus event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(FavoritesLoading());
      log('🔄 Loading favorite status for ${event.duaIds.length} duas');

      // Load all favorites from local storage
      final allFavorites = await FavoritesService.getLocalFavorites();
      
      // Filter only the duas we're interested in
      final favoritedDuas = allFavorites.intersection(Set<String>.from(event.duaIds));

      log('✅ Loaded favorite status. Favorited duas: ${favoritedDuas.length}');
      emit(FavoritesLoaded(favoritedDuas));
    } catch (e) {
      log('❌ Error loading favorite status: $e');
      emit(FavoritesFailure(e.toString()));
    }
  }

  Future<void> _onToggleDuaFavorite(
    ToggleDuaFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      log('🔄 Toggling favorite for dua: ${event.duaId}');
      
      final success = await FavoritesService.toggleDuaFavorite(event.duaId);
      
      if (success) {
        // Get current state
        if (state is FavoritesLoaded) {
          final currentState = state as FavoritesLoaded;
          final updatedFavorites = Set<String>.from(currentState.favoritedDuas);
          
          if (updatedFavorites.contains(event.duaId)) {
            updatedFavorites.remove(event.duaId);
            log('✅ Removed dua ${event.duaId} from favorites');
          } else {
            updatedFavorites.add(event.duaId);
            log('✅ Added dua ${event.duaId} to favorites');
          }
          
          emit(FavoritesLoaded(updatedFavorites));
        }
      } else {
        log('❌ Failed to toggle favorite for dua: ${event.duaId}');
        // Check if it's because user is not logged in
        final isLoggedIn = await SecureStorageManager.isLoggedIn();
        if (!isLoggedIn) {
          emit(FavoritesFailure('Please login to add favorites'));
        } else {
          emit(FavoritesFailure('Failed to toggle favorite'));
        }
      }
    } catch (e) {
      log('❌ Error toggling favorite: $e');
      emit(FavoritesFailure(e.toString()));
    }
  }

  Future<void> _onClearFavorites(
    ClearFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoaded({}));
  }
}
