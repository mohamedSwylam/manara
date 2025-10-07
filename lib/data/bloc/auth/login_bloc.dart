import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../services/auth_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState(status: LoginStatus.initial)) {
    on<LoginUser>(_onLoginUser);
    on<ToggleLoginPasswordVisibility>(_onToggleLoginPasswordVisibility);
    on<ValidateLoginForm>(_onValidateLoginForm);
    on<ResetLoginForm>(_onResetLoginForm);
  }

  Future<void> _onLoginUser(
    LoginUser event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    
    try {
      log('Starting login process...');
      
      final response = await AuthService.login(event.request);

      emit(state.copyWith(
        status: LoginStatus.success,
        response: response,
      ));

      log('Login completed successfully');
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      
      if (e.response?.statusCode == 422) {
        // Try to get error message from response
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? 'Please check your credentials and try again';
          } else {
            errorMessage = 'Please check your credentials and try again';
          }
        } catch (e) {
          errorMessage = 'Please check your credentials and try again';
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'User not found';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Bad request';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      log('Login error: $errorMessage');
      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: errorMessage,
      ));    } catch (e) {
      log('Unexpected error during login: $e');
      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  void _onToggleLoginPasswordVisibility(
    ToggleLoginPasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  void _onValidateLoginForm(
    ValidateLoginForm event,
    Emitter<LoginState> emit,
  ) {
    try {
      String? emailError;
      String? passwordError;
      bool isFormValid = true;

      // Validate email
      if (event.email.trim().isEmpty) {
        emailError = 'Email is required';
        isFormValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(event.email.trim())) {
        emailError = 'Please enter a valid email address';
        isFormValid = false;
      }

      // Validate password
      if (event.password.isEmpty) {
        passwordError = 'Password is required';
        isFormValid = false;
      }

      emit(state.copyWith(
        isFormValid: isFormValid,
        emailError: emailError,
        passwordError: passwordError,
      ));

    } catch (e) {
      log('Form validation error: $e');

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Form validation failed',

      ));

    }
  }

  void _onResetLoginForm(
    ResetLoginForm event,
    Emitter<LoginState> emit,
  ) {

    emit(state.copyWith(
      status: LoginStatus.initial,
      errorMessage: 'Form validation failed',

    ));
  }
}
