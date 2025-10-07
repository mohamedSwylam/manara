import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/dua_service.dart';
import 'dua_categories_event.dart';
import 'dua_categories_state.dart';

class DuaCategoriesBloc extends Bloc<DuaCategoriesEvent, DuaCategoriesState> {
  DuaCategoriesBloc() : super(DuaCategoriesInitial()) {
    on<LoadDuaCategories>(_onLoadDuaCategories);
    on<RefreshDuaCategories>(_onRefreshDuaCategories);
  }

  Future<void> _onLoadDuaCategories(
    LoadDuaCategories event,
    Emitter<DuaCategoriesState> emit,
  ) async {
    try {
      emit(DuaCategoriesLoading());
      
      final result = await DuaService.getDuaCategoriesWithCache();
      
      if (result.isFromExpiredCache) {
        emit(DuaCategoriesLoadedOffline(
          result.categories,
          'Showing cached data (may be outdated). Connect to internet for latest updates.',
        ));
      } else {
        emit(DuaCategoriesLoaded(result.categories));
      }
    } catch (e) {
      // Check if it's an offline error
      if (e.toString().contains('No internet connection and no cached data available')) {
        emit(const DuaCategoriesOffline('You are offline and no cached data is available. Please connect to the internet to load dua categories for the first time.'));
      } else {
        emit(DuaCategoriesFailure(e.toString()));
      }
    }
  }

  Future<void> _onRefreshDuaCategories(
    RefreshDuaCategories event,
    Emitter<DuaCategoriesState> emit,
  ) async {
    try {
      emit(DuaCategoriesLoading());
      
      final categories = await DuaService.getDuaCategories();
      
      emit(DuaCategoriesLoaded(categories));
    } catch (e) {
      emit(DuaCategoriesFailure(e.toString()));
    }
  }
}
