import 'package:equatable/equatable.dart';
import '../../models/auth/register_response_model.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final RegisterResponseModel response;

  const RegisterSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class RegisterFormState extends RegisterState {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isFormValid;
  final String? fullNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  const RegisterFormState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isFormValid = false,
    this.fullNameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  RegisterFormState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isFormValid,
    String? fullNameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) {
    return RegisterFormState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isFormValid: isFormValid ?? this.isFormValid,
      fullNameError: fullNameError ?? this.fullNameError,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
    );
  }

  @override
  List<Object?> get props => [
        isPasswordVisible,
        isConfirmPasswordVisible,
        isFormValid,
        fullNameError,
        emailError,
        passwordError,
        confirmPasswordError,
      ];
}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError(this.message);

  @override
  List<Object?> get props => [message];
}
