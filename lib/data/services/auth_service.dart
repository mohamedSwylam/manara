import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/auth/register_request_model.dart';
import '../models/auth/register_response_model.dart' hide UserData, FileUrl;
import '../models/auth/login_request_model.dart';
import '../models/auth/login_response_model.dart';
import '../models/auth/change_password_request_model.dart';
import '../models/auth/change_password_response_model.dart';
import '../utility/api_constants.dart';
import '../utility/token_manager.dart';
import '../utility/secure_storage_manager.dart';
import 'dio_helper.dart';
import 'dart:convert';

class AuthService {
  // Register user
  static Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      log('Registering user: ${request.fullName}');
      
      final response = await DioHelper.post(
        ApiConstants.register,
        data: request.toApiFormat(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final registerResponse = RegisterResponseModel.fromJson(response.data);
        
        // Save authentication data to secure storage
        try {
          await SecureStorageManager.saveAuthData(
            token: registerResponse.token,
            userId: registerResponse.userData.id,
            userDataJson: jsonEncode(registerResponse.userData.toJson()),
          );
        } catch (e) {
          log('Warning: Could not save to secure storage, using fallback: $e');
        }
        
        // Also save to legacy token manager for backward compatibility
        await AuthController.setAccessToken(registerResponse.token);
        
        log('User registered successfully: ${registerResponse.userData.fullName}');
        return registerResponse;
      } else {
        // Handle error responses
        log('Registration failed with status: ${response.statusCode}');
        log('Response data: ${response.data}');
        
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Registration failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('Registration error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error during registration: $e');
      rethrow;
    }
  }
  
  // Login user
  static Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      log('Logging in user: ${request.email}');
      
      final response = await DioHelper.post(
        ApiConstants.login,
        data: request.toApiFormat(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = LoginResponseModel.fromJson(response.data);
        
        // Save authentication data to secure storage
        try {
          await SecureStorageManager.saveAuthData(
            token: loginResponse.token,
            userId: loginResponse.userData.id,
            userDataJson: jsonEncode(loginResponse.userData.toJson()),
          );
        } catch (e) {
          log('Warning: Could not save to secure storage, using fallback: $e');
        }
        
        // Also save to legacy token manager for backward compatibility
        await AuthController.setAccessToken(loginResponse.token);
        
        log('User logged in successfully: ${loginResponse.userData.fullName}');
        return loginResponse;
      } else {
        // Handle error responses
        log('Login failed with status: ${response.statusCode}');
        log('Response data: ${response.data}');
        
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('Login error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error during login: $e');
      rethrow;
    }
  }
  
  // Logout user
  static Future<void> logout() async {
    try {
      if (AuthController.isLoggedIn) {
        await DioHelper.post(ApiConstants.logout);
      }
    } catch (e) {
      log('Logout error: $e');
    } finally {
      // Clear all authentication data from secure storage
      await SecureStorageManager.logout();
      // Also clear from legacy token manager for backward compatibility
      await AuthController.clearTokenValue();
    }
  }
  
  // Check if user is authenticated
  static bool get isAuthenticated => AuthController.isLoggedIn;
  
  // Get current user token
  static String? get currentToken => AuthController.accessToken;
  
  // Find user by ID
  static Future<UserData?> findUserById(String userId) async {
    try {
      log('Finding user with ID: $userId');
      
      final response = await DioHelper.get('${ApiConstants.findUser}/$userId');
      
      if (response.statusCode == 200) {
        final userData = UserData.fromJson(response.data);
        log('User found: ${userData.fullName}');
        return userData;
      } else {
        log('User not found with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      log('Find user error: ${e.message}');
      return null;
    } catch (e) {
      log('Unexpected error during find user: $e');
      return null;
    }
  }

  // Change password
  static Future<ChangePasswordResponseModel> changePassword(ChangePasswordRequestModel request) async {
    try {
      log('Changing password...');
      
      final response = await DioHelper.post(
        ApiConstants.changePasswordReset,
        data: request.toApiFormat(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final changePasswordResponse = ChangePasswordResponseModel.fromJson(response.data);
        log('Password changed successfully');
        return changePasswordResponse;
      } else {
        // Handle error responses
        log('Password change failed with status: ${response.statusCode}');
        log('Response data: ${response.data}');
        
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Password change failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('Password change error: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error during password change: $e');
      rethrow;
    }
  }
}
