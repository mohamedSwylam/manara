import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/auth_service.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc() : super(ChangePasswordFormState()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
    on<ToggleChangePasswordVisibility>(_onTogglePasswordVisibility);
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    try {
      emit(ChangePasswordLoading());
      
      final response = await AuthService.changePassword(event.request);
      
      emit(ChangePasswordSuccess(response));
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }

  void _onTogglePasswordVisibility(
    ToggleChangePasswordVisibility event,
    Emitter<ChangePasswordState> emit,
  ) {
    if (state is ChangePasswordFormState) {
      final currentState = state as ChangePasswordFormState;
      
      switch (event.field) {
        case 'current':
          emit(currentState.copyWith(
            isCurrentPasswordVisible: !currentState.isCurrentPasswordVisible,
          ));
          break;
        case 'new':
          emit(currentState.copyWith(
            isNewPasswordVisible: !currentState.isNewPasswordVisible,
          ));
          break;
        case 'confirm':
          emit(currentState.copyWith(
            isConfirmPasswordVisible: !currentState.isConfirmPasswordVisible,
          ));
          break;
      }
    }
  }
}
