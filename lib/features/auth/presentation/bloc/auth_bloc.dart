import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(AuthInitial()) {

    on<LoginPressed>(_onLoginPressed);

    on<RegisterPressed>(_onRegisterPressed);
  }

  Future<void> _onLoginPressed(
    LoginPressed event,
    Emitter<AuthState> emit,
  ) async {

    emit(AuthLoading());

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (
      event.email.isNotEmpty &&
      event.password.isNotEmpty
    ) {

      emit(AuthSuccess());

    } else {

      emit(
        AuthError(
          'Completa todos los campos',
        ),
      );
    }
  }

  Future<void> _onRegisterPressed(
    RegisterPressed event,
    Emitter<AuthState> emit,
  ) async {

    emit(AuthLoading());

    await Future.delayed(
      const Duration(seconds: 2),
    );

    emit(AuthSuccess());
  }
}