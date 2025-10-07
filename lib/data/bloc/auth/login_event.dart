import 'package:equatable/equatable.dart';
import '../../models/auth/login_request_model.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginUser extends LoginEvent {
  final LoginRequestModel request;

  const LoginUser({required this.request});

  @override
  List<Object?> get props => [request];
}

class ToggleLoginPasswordVisibility extends LoginEvent {
  const ToggleLoginPasswordVisibility();
}

class ValidateLoginForm extends LoginEvent {
  final String email;
  final String password;
  final String oneSignalId;

  const ValidateLoginForm({
    required this.email,
    required this.password,
    required this.oneSignalId,
  });

  @override
  List<Object?> get props => [email, password, oneSignalId];
}

class ResetLoginForm extends LoginEvent {
  const ResetLoginForm();
}
