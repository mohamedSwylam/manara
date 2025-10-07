import 'package:equatable/equatable.dart';
import '../../models/auth/login_response_model.dart';
enum LoginStatus { initial, loading, success, error }

class LoginState extends Equatable {
  final bool isPasswordVisible;
  final bool isFormValid;
  final String? emailError;
  final String? passwordError;
  final LoginStatus status;
  final LoginResponseModel? response;
  final String? errorMessage;

  const LoginState({
    this.isPasswordVisible = false,
    this.isFormValid = false,
    this.emailError,
    this.passwordError,
    this.status = LoginStatus.initial,
    this.response,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isPasswordVisible,
    bool? isFormValid,
    String? emailError,
    String? passwordError,
    LoginStatus? status,
    LoginResponseModel? response,
    String? errorMessage,
  }) {
    return LoginState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isFormValid: isFormValid ?? this.isFormValid,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isPasswordVisible,
    isFormValid,
    emailError,
    passwordError,
    status,
    response,
    errorMessage,
  ];
}
