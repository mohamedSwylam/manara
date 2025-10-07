import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthLoaded()) {
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ValidateForm>(_onValidateForm);
    on<ResetForm>(_onResetForm);
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthLoaded) {
      final currentState = state as AuthLoaded;
      emit(currentState.copyWith(
        isPasswordVisible: !currentState.isPasswordVisible,
      ));
    }
  }

  void _onValidateForm(
    ValidateForm event,
    Emitter<AuthState> emit,
  ) {
          emit(AuthLoading());

    try {
      String? emailError;
      String? passwordError;
      bool isFormValid = true;

      // Validate email
      if (event.email.isEmpty) {
        emailError = 'email_required';
        isFormValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(event.email)) {
        emailError = 'email_invalid';
        isFormValid = false;
      }

      // Validate password
      if (event.password.isEmpty) {
        passwordError = 'password_required';
        isFormValid = false;
      } else if (event.password.length < 6) {
        passwordError = 'password_min_length';
        isFormValid = false;
      }

      if (state is AuthLoaded) {
        final currentState = state as AuthLoaded;
        emit(currentState.copyWith(
          isFormValid: isFormValid,
          emailError: emailError,
          passwordError: passwordError,
        ));
      } else {
        emit(AuthLoaded(
          isFormValid: isFormValid,
          emailError: emailError,
          passwordError: passwordError,
        ));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onResetForm(
    ResetForm event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthLoaded());
  }
}
