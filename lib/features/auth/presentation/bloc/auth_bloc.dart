import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../domain/usecases/registro_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/entities/usuario.dart';
import '../../data/models/usuario_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/storage/token_storage_service.dart';
import '../../domain/usecases/confirmar_codigo_usecase.dart';
import '../../domain/usecases/enviar_codigo_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final EnviarCodigoUseCase enviarCodigoUseCase;
  final ConfirmarCodigoUseCase confirmarCodigoUseCase;
  final TokenStorageService tokenStorage;

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.enviarCodigoUseCase,
    required this.confirmarCodigoUseCase,
    required this.tokenStorage,
  }) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<VerificarSesionEvent>(_onVerificarSesion);
    on<EnviarCodigoEvent>(_onEnviarCodigo);
    on<ConfirmarCodigoEvent>(_onConfirmarCodigo);
    on<ActualizarUsuarioEvent>((event, emit) {
      emit(AuthSuccess(message: 'Perfil actualizado', data: event.usuario));
    });
    on<LogoutEvent>((event, emit) async {
      await tokenStorage.borrarToken();
      emit(AuthInitial());
    });
  }

  Future<void> _onEnviarCodigo(
    EnviarCodigoEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await enviarCodigoUseCase.call(event.correo);
      emit(AuthSuccess(message: 'Código enviado'));
    } catch (e) {
      emit(AuthError(message: mensajeDeError(e)));
    }
  }

  Future<void> _onConfirmarCodigo(
    ConfirmarCodigoEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await confirmarCodigoUseCase.call(event.correo, event.codigo);
      emit(AuthSuccess(message: 'Código confirmado'));
    } catch (e) {
      emit(AuthError(message: mensajeDeError(e)));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usuario = await registerUseCase.call(
        correo: event.correo,
        nombreUsuario: event.nombreUsuario,
        password: event.password,
        nombre: event.nombre,
        apellidos: event.apellidos,
        numTelefono: event.numTelefono,
        fechaNacimiento: event.fechaNacimiento,
        organizacion: event.organizacion,
      );
      emit(AuthSuccess(message: 'Registro exitoso', data: usuario));
    } catch (e) {
      emit(AuthError(message: mensajeDeError(e)));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final token = await loginUseCase(event.identificador, event.password);
      await tokenStorage.guardarToken(token.accessToken);

      if (token.user != null) {
        await tokenStorage.guardarUsuario(
          jsonEncode(_usuarioToJson(token.user!)),
        );
      }

      emit(AuthSuccess(message: 'Inicio de sesión exitoso', data: token.user));
    } catch (e) {
      emit(AuthError(message: 'Identificador o contraseña incorrectos.'));
    }
  }

  Future<void> _onVerificarSesion(
    VerificarSesionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await tokenStorage.obtenerToken();
      final usuarioJson = await tokenStorage.obtenerUsuarioJson();

      if (token == null || usuarioJson == null) {
        emit(AuthInitial());
        return;
      }

      if (_tokenExpirado(token)) {
        await tokenStorage.borrarToken();
        emit(AuthInitial());
        return;
      }

      final usuario = UsuarioModel.fromJson(jsonDecode(usuarioJson));
      emit(AuthSuccess(message: 'Sesión restaurada', data: usuario));
    } catch (_) {
      await tokenStorage.borrarToken();
      emit(AuthInitial());
    }
  }

  bool _tokenExpirado(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
      );

      final exp = payload['exp'];
      if (exp == null) return true;

      final expiracion = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiracion);
    } catch (_) {
      return true;
    }
  }

  Map<String, dynamic> _usuarioToJson(Usuario u) {
    return {
      'usuario_id_pk': u.usuarioIdPk,
      'correo': u.correo,
      'nombre': u.nombre,
      'apellidos': u.apellidos,
      'nombre_usuario': u.nombreUsuario,
      'num_telefono': u.numTelefono,
      'fecha_nacimiento': u.fechaNacimiento.toIso8601String().split('T')[0],
      'verificado': u.verificado,
      'fecha_registro_usuario': u.fechaRegistroUsuario.toIso8601String(),
      'rol_usuario': u.rolUsuario,
      'calle': u.calle,
      'colonia': u.colonia,
      'cp': u.cp,
      'ciudad': u.ciudad,
      'estado': u.estado,
      'foto_perfil': u.fotoPerfil,
    };
  }
}