import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}

class ValidateForm extends AuthEvent {
  final String email;
  final String password;

  const ValidateForm({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class ResetForm extends AuthEvent {
  const ResetForm();
}
