import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../utility/api_constants.dart';
import '../utility/token_manager.dart';
import '../utility/secure_storage_manager.dart';

class DioHelper {
  static Dio? _dio;
  
  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }
  
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: ApiConstants.defaultHeaders,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          // Don't throw exceptions for 4xx status codes, let us handle them
          return status != null && status < 500;
        },
      ),
    );
    
    // Add interceptors
    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);
    
    return dio;
  }
  
  // GET request
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {

    print("endpoint: $endpoint");
    print("queryParameters: ${queryParameters}");
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      log('GET request error: $e');
      rethrow;
    }
  }
  
  // POST request
  static Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // For form data requests (like register), use FormData
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final formData = FormData.fromMap({
          'data': jsonEncode(data['data']),
        });
        print("endpoint: $endpoint");
        print("formData: ${formData.fields}");

        final response = await dio.post(
          endpoint,
          data: formData,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        return response;
      } else {
        // For regular JSON requests

        print("endpoint: $endpoint");
        print("Data: ${data}");
        final response = await dio.post(
          endpoint,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        return response;
      }
    } catch (e) {
      log('POST request error: $e');
      rethrow;
    }
  }
  
  // PUT request
  static Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {

    print("endpoint: $endpoint");
    print("formData: ${data}");
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      log('PUT request error: $e');
      rethrow;
    }
  }
  
  // DELETE request
  static Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      log('DELETE request error: $e');
      rethrow;
    }
  }
  
  // PATCH request
  static Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      log('PATCH request error: $e');
      rethrow;
    }
  }
}

// Logging Interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('REQUEST[${options.method}] => PATH: ${options.path}');
    log('REQUEST[${options.method}] => DATA: ${options.data}');
    log('REQUEST[${options.method}] => HEADERS: ${options.headers}');
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    log('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    log('ERROR[${err.response?.statusCode}] => MESSAGE: ${err.message}');
    super.onError(err, handler);
  }
}

// Auth Interceptor
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add auth token from secure storage if available
    final token = await SecureStorageManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        log('Timeout error');
        break;
      case DioExceptionType.badResponse:
        log('Bad response error: ${err.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        log('Request cancelled');
        break;
      case DioExceptionType.connectionError:
        log('Connection error');
        break;
      case DioExceptionType.unknown:
        log('Unknown error');
        break;
      case DioExceptionType.badCertificate:
        log('Bad certificate error');
        break;
    }
    super.onError(err, handler);
  }
}
