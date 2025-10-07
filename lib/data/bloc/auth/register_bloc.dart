import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../../services/auth_service.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterFormState()) {
    on<RegisterUser>(_onRegisterUser);
    on<ToggleRegisterPasswordVisibility>(_onToggleRegisterPasswordVisibility);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<ValidateRegisterForm>(_onValidateRegisterForm);
    on<ResetRegisterForm>(_onResetRegisterForm);
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    
    try {
      log('Starting registration process...');
      
      final response = await AuthService.register(event.request);
      
      emit(RegisterSuccess(response: response));
      
      log('Registration completed successfully');
    } on DioException catch (e) {
      String errorMessage = 'Registration failed';
      
      if (e.response?.statusCode == 422) {
        // Try to get error message from response
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? 'Please check your input data and try again';
          } else {
            errorMessage = 'Please check your input data and try again';
          }
        } catch (e) {
          errorMessage = 'Please check your input data and try again';
        }
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'User already exists with this email';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Bad request';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      log('Registration error: $errorMessage');
      emit(RegisterError(errorMessage));
    } catch (e) {
      log('Unexpected error during registration: $e');
      emit(RegisterError('An unexpected error occurred. Please try again.'));
    }
  }

  void _onToggleRegisterPasswordVisibility(
    ToggleRegisterPasswordVisibility event,
    Emitter<RegisterState> emit,
  ) {
    if (state is RegisterFormState) {
      final currentState = state as RegisterFormState;
      emit(currentState.copyWith(
        isPasswordVisible: !currentState.isPasswordVisible,
      ));
    }
  }

  void _onToggleConfirmPasswordVisibility(
    ToggleConfirmPasswordVisibility event,
    Emitter<RegisterState> emit,
  ) {
    if (state is RegisterFormState) {
      final currentState = state as RegisterFormState;
      emit(currentState.copyWith(
        isConfirmPasswordVisible: !currentState.isConfirmPasswordVisible,
      ));
    }
  }

  void _onValidateRegisterForm(
    ValidateRegisterForm event,
    Emitter<RegisterState> emit,
  ) {
    try {
      String? fullNameError;
      String? emailError;
      String? passwordError;
      String? confirmPasswordError;
      bool isFormValid = true;

      // Validate full name
      if (event.fullName.trim().isEmpty) {
        fullNameError = 'Full name is required';
        isFormValid = false;
      } else if (event.fullName.trim().length < 2) {
        fullNameError = 'Full name must be at least 2 characters';
        isFormValid = false;
      }

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
      } else if (event.password.length < 8) {
        passwordError = 'Password must be at least 8 characters';
        isFormValid = false;
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(event.password)) {
        passwordError = 'Password must contain uppercase, lowercase, number and special character';
        isFormValid = false;
      }

      // Validate confirm password
      if (event.confirmPassword.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
        isFormValid = false;
      } else if (event.password != event.confirmPassword) {
        confirmPasswordError = 'Passwords do not match';
        isFormValid = false;
      }

      emit(RegisterFormState(
        isPasswordVisible: state is RegisterFormState ? (state as RegisterFormState).isPasswordVisible : false,
        isConfirmPasswordVisible: state is RegisterFormState ? (state as RegisterFormState).isConfirmPasswordVisible : false,
        isFormValid: isFormValid,
        fullNameError: fullNameError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      ));
    } catch (e) {
      log('Form validation error: $e');
      emit(RegisterError('Form validation failed'));
    }
  }

  void _onResetRegisterForm(
    ResetRegisterForm event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegisterFormState());
  }
}
