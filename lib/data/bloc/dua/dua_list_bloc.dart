import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/dua_service.dart';
import 'dua_list_event.dart';
import 'dua_list_state.dart';

class DuaListBloc extends Bloc<DuaListEvent, DuaListState> {
  DuaListBloc() : super(DuaListInitial()) {
    on<LoadDuasByCategory>(_onLoadDuasByCategory);
    on<RefreshDuasByCategory>(_onRefreshDuasByCategory);
  }

  Future<void> _onLoadDuasByCategory(
    LoadDuasByCategory event,
    Emitter<DuaListState> emit,
  ) async {
    try {
      emit(DuaListLoading());
      
      final duas = await DuaService.getDuasByCategory(event.categoryId);
      
      emit(DuaListLoaded(duas, event.categoryId));
    } catch (e) {
      emit(DuaListFailure(e.toString()));
    }
  }

  Future<void> _onRefreshDuasByCategory(
    RefreshDuasByCategory event,
    Emitter<DuaListState> emit,
  ) async {
    try {
      emit(DuaListLoading());
      
      final duas = await DuaService.getDuasByCategory(event.categoryId);
      
      emit(DuaListLoaded(duas, event.categoryId));
    } catch (e) {
      emit(DuaListFailure(e.toString()));
    }
  }
}
