import 'dart:developer';
import 'package:dio/dio.dart';
import '../utility/api_constants.dart';
import '../models/azkar/azkar_category_model.dart';
import '../models/azkar/azkar_tracking_model.dart';
import '../models/azkar/azkar_model.dart';

class AzkarService {
  static final Dio _dio = Dio();

  /// Fetch azkar categories from API
  static Future<List<AzkarCategoryModel>> getAzkarCategories() async {
    try {
      log('🔄 Fetching azkar categories...');
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.azkarCategories}',
        options: Options(
          headers: ApiConstants.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final categories = data.map((json) => AzkarCategoryModel.fromJson(json)).toList();
        
        log('✅ Azkar categories fetched successfully: ${categories.length} categories');
        return categories;
      } else {
        log('❌ Failed to fetch azkar categories: ${response.statusCode}');
        throw Exception('Failed to fetch azkar categories');
      }
    } catch (e) {
      log('❌ Error fetching azkar categories: $e');
      if (e is DioException) {
        log('📡 Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Fetch azkar tracking progress from API
  static Future<List<AzkarTrackingModel>> getAzkarTracking() async {
    try {
      log('🔄 Fetching azkar tracking progress...');
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.azkarTracking}',
        options: Options(
          headers: ApiConstants.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final tracking = data.map((json) => AzkarTrackingModel.fromJson(json)).toList();
        
        log('✅ Azkar tracking fetched successfully: ${tracking.length} categories');
        return tracking;
      } else {
        log('❌ Failed to fetch azkar tracking: ${response.statusCode}');
        throw Exception('Failed to fetch azkar tracking');
      }
    } catch (e) {
      log('❌ Error fetching azkar tracking: $e');
      if (e is DioException) {
        log('📡 Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Fetch azkars by category from API
  static Future<List<AzkarModel>> getAzkarsByCategory(String categoryId) async {
    try {
      log('🔄 Fetching azkars for category: $categoryId');
      log('🌐 API URL: ${ApiConstants.baseUrl}${ApiConstants.azkarsByCategory}/$categoryId');

      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.azkarsByCategory}/$categoryId',
        options: Options(
          headers: ApiConstants.defaultHeaders,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      log('📡 Response status: ${response.statusCode}');
      log('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final azkars = data.map((json) => AzkarModel.fromJson(json)).toList();

        log('✅ Azkars fetched successfully: ${azkars.length} azkars');
        log('📊 Total repeat count: ${azkars.fold(0, (sum, azkar) => sum + azkar.repeatCount)}');
        return azkars;
      } else {
        log('❌ Failed to fetch azkars: ${response.statusCode}');
        throw Exception('Failed to fetch azkars');
      }
    } catch (e) {
      log('❌ Error fetching azkars: $e');
      if (e is DioException) {
        log('📡 Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Track azkar completion
  static Future<void> trackAzkarCompletion(String azkarId) async {
    try {
      log('🔄 Tracking azkar completion for azkar: $azkarId');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.azkarTrackingRepeat}/$azkarId',
        options: Options(
          headers: ApiConstants.defaultHeaders,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      log('📡 Tracking response status: ${response.statusCode}');
      log('📡 Tracking response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('✅ Azkar completion tracked successfully');
      } else {
        log('❌ Failed to track azkar completion: ${response.statusCode}');
        throw Exception('Failed to track azkar completion');
      }
    } catch (e) {
      log('❌ Error tracking azkar completion: $e');
      if (e is DioException) {
        log('📡 Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      // Don't rethrow - we don't want to break the user experience if tracking fails
    }
  }
}
