import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/registro_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
  }) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usuario = await registerUseCase.call(
        correo: event.correo,
        password: event.password,
        nombre: event.nombre,
        apellidos: event.apellidos,
        numTelefono: event.numTelefono,
        fechaNacimiento: event.fechaNacimiento,
      );
      emit(AuthSuccess(message: 'Registro exitoso', data: usuario));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await loginUseCase.call(event.correo, event.password);
      emit(AuthSuccess(message: 'Login exitoso', data: token));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}