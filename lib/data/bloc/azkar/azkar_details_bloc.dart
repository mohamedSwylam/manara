import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/azkar_service.dart';
import '../../models/azkar/azkar_model.dart';
import 'azkar_details_event.dart';
import 'azkar_details_state.dart';

class AzkarDetailsBloc extends Bloc<AzkarDetailsEvent, AzkarDetailsState> {
  AzkarDetailsBloc() : super(AzkarDetailsInitial()) {
    on<LoadAzkarsByCategory>(_onLoadAzkarsByCategory);
    on<RefreshAzkarsByCategory>(_onRefreshAzkarsByCategory);
  }

  Future<void> _onLoadAzkarsByCategory(
    LoadAzkarsByCategory event,
    Emitter<AzkarDetailsState> emit,
  ) async {
    try {
      emit(AzkarDetailsLoading());
      log('🔄 Loading azkars for category: ${event.categoryId}');

      final azkars = await AzkarService.getAzkarsByCategory(event.categoryId);

      log('✅ Azkars loaded successfully: ${azkars.length} azkars');
      log('📊 Total repeat count in bloc: ${azkars.fold(0, (sum, azkar) => sum + azkar.repeatCount)}');
      emit(AzkarDetailsLoaded(
        azkars: azkars,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      log('❌ Error loading azkars: $e');
      log('❌ Error type: ${e.runtimeType}');
      emit(AzkarDetailsFailure(e.toString()));
    }
  }

  Future<void> _onRefreshAzkarsByCategory(
    RefreshAzkarsByCategory event,
    Emitter<AzkarDetailsState> emit,
  ) async {
    try {
      log('🔄 Refreshing azkars for category: ${event.categoryId}');

      final azkars = await AzkarService.getAzkarsByCategory(event.categoryId);

      log('✅ Azkars refreshed successfully: ${azkars.length} azkars');
      emit(AzkarDetailsLoaded(
        azkars: azkars,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      log('❌ Error refreshing azkars: $e');
      emit(AzkarDetailsFailure(e.toString()));
    }
  }
}
