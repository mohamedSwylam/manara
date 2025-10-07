import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/azkar_service.dart';
import '../../models/azkar/azkar_category_model.dart';
import '../../models/azkar/azkar_tracking_model.dart';
import 'azkar_event.dart';
import 'azkar_state.dart';

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  AzkarBloc() : super(AzkarInitial()) {
    on<LoadAzkarData>(_onLoadAzkarData);
    on<RefreshAzkarData>(_onRefreshAzkarData);
  }

  Future<void> _onLoadAzkarData(
    LoadAzkarData event,
    Emitter<AzkarState> emit,
  ) async {
    try {
      emit(AzkarLoading());
      log('🔄 Loading azkar data...');

      // Fetch both categories and tracking in parallel
      final results = await Future.wait([
        AzkarService.getAzkarCategories(),
        AzkarService.getAzkarTracking(),
      ]);

      final categories = results[0] as List<dynamic>;
      final tracking = results[1] as List<dynamic>;

      log('✅ Azkar data loaded successfully');
      emit(AzkarLoaded(
        categories: categories.cast<AzkarCategoryModel>(),
        tracking: tracking.cast<AzkarTrackingModel>(),
      ));
    } catch (e) {
      log('❌ Error loading azkar data: $e');
      emit(AzkarFailure(e.toString()));
    }
  }

  Future<void> _onRefreshAzkarData(
    RefreshAzkarData event,
    Emitter<AzkarState> emit,
  ) async {
    try {
      log('🔄 Refreshing azkar data...');

      // Fetch both categories and tracking in parallel
      final results = await Future.wait([
        AzkarService.getAzkarCategories(),
        AzkarService.getAzkarTracking(),
      ]);

      final categories = results[0] as List<dynamic>;
      final tracking = results[1] as List<dynamic>;

      log('✅ Azkar data refreshed successfully');
      emit(AzkarLoaded(
        categories: categories.cast<AzkarCategoryModel>(),
        tracking: tracking.cast<AzkarTrackingModel>(),
      ));
    } catch (e) {
      log('❌ Error refreshing azkar data: $e');
      emit(AzkarFailure(e.toString()));
    }
  }
}
