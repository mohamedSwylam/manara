import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  final bool isPasswordVisible;
  final bool isFormValid;
  final String? emailError;
  final String? passwordError;

  const AuthLoaded({
    this.isPasswordVisible = false,
    this.isFormValid = false,
    this.emailError,
    this.passwordError,
  });

  AuthLoaded copyWith({
    bool? isPasswordVisible,
    bool? isFormValid,
    String? emailError,
    String? passwordError,
  }) {
    return AuthLoaded(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isFormValid: isFormValid ?? this.isFormValid,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
    );
  }

  @override
  List<Object?> get props => [
        isPasswordVisible,
        isFormValid,
        emailError,
        passwordError,
      ];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
