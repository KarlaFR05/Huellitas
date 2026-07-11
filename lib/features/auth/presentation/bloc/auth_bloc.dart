import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/registro_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/storage/token_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final TokenStorageService tokenStorage;

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<ActualizarUsuarioEvent>((event, emit) {
      emit(AuthSuccess(message: 'Perfil actualizado', data: event.usuario));
    });
    on<LogoutEvent>((event, emit) async {
      await tokenStorage.borrarToken();
      emit(AuthInitial());
    });
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
      final token = await loginUseCase(event.correo, event.password);
      await tokenStorage.guardarToken(token.accessToken);

      emit(AuthSuccess(message: 'Inicio de sesión exitoso', data: token.user));
    } catch (e) {
      emit(AuthError(message: 'Correo o contraseña incorrectos.'));
    }
  }
}
