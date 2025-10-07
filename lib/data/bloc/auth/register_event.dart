import 'package:equatable/equatable.dart';
import '../../models/auth/register_request_model.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterUser extends RegisterEvent {
  final RegisterRequestModel request;

  const RegisterUser({required this.request});

  @override
  List<Object?> get props => [request];
}

class ToggleRegisterPasswordVisibility extends RegisterEvent {
  const ToggleRegisterPasswordVisibility();
}

class ToggleConfirmPasswordVisibility extends RegisterEvent {
  const ToggleConfirmPasswordVisibility();
}

class ValidateRegisterForm extends RegisterEvent {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String oneSignalId;

  const ValidateRegisterForm({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.oneSignalId,
  });

  @override
  List<Object?> get props => [fullName, email, password, confirmPassword, oneSignalId];
}

class ResetRegisterForm extends RegisterEvent {
  const ResetRegisterForm();
}
