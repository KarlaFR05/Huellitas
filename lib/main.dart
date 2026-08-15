import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/registro_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/enviar_codigo_usecase.dart';
import 'features/auth/domain/usecases/confirmar_codigo_usecase.dart';
import 'core/storage/token_storage_service.dart';
import 'features/completar_registro/data/datasources/completar_perfil_remote_datasource.dart';
import 'features/completar_registro/data/repositories/completar_perfil_repository_impl.dart';
import 'features/completar_registro/presentation/bloc/completar_perfil_bloc.dart';
import 'core/verificacion/verificacion_cubit.dart';
import 'features/insignias/data/datasources/insignia_remote_datasource_impl.dart';
import 'features/insignias/data/repositories/insignia_repository_impl.dart';
import 'features/insignias/domain/usecases/get_insignias_usuario_usecase.dart';
import 'features/insignias/presentation/bloc/insignia_bloc.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'features/donaciones/data/datasources/donacion_remote_datasource.dart';
import 'features/donaciones/data/repositories/donacion_repository_impl.dart';
import 'features/donaciones/domain/usecases/obtener_organizaciones_usecase.dart';
import 'features/donaciones/domain/usecases/crear_donacion_usecase.dart';
import 'features/donaciones/presentation/bloc/donacion_bloc.dart';
import 'features/donaciones/data/datasources/tarjeta_remote_datasource.dart';
import 'features/donaciones/data/repositories/tarjeta_repository_impl.dart';
import 'features/donaciones/domain/usecases/obtener_tarjetas_usecase.dart';
import 'features/donaciones/domain/usecases/guardar_tarjeta_usecase.dart';
import 'features/donaciones/domain/usecases/eliminar_tarjeta_usecase.dart';
import 'features/donaciones/presentation/bloc/tarjeta/tarjeta_bloc.dart';
import 'features/donaciones/domain/usecases/actualizar_tarjeta_usecase.dart';
import 'features/donaciones/domain/usecases/establecer_predeterminada_usecase.dart';

import 'features/foro/data/datasources/foro_remote_datasource_impl.dart';
import 'features/foro/data/repositories/foro_repository_impl.dart';
import 'features/foro/domain/repositories/foro_repository.dart';
import 'features/reporte/data/datasources/reporte_remote_datasource_impl.dart';
import 'features/reporte/data/repositories/reporte_repository_impl.dart';
import 'features/reporte/domain/repositories/reporte_repository.dart';

import 'features/donaciones/data/datasources/historial_remote_datasource.dart';
import 'features/donaciones/data/repositories/historial_repository_impl.dart';
import 'features/donaciones/domain/usecases/obtener_historial_donaciones_usecase.dart';
import 'features/donaciones/presentation/bloc/historial_bloc.dart';

import 'features/notificaciones/data/datasources/notificacion_remote_datasource.dart';
import 'features/notificaciones/data/repositories/notificacion_repository_impl.dart';
import 'features/notificaciones/presentation/bloc/notificacion_bloc.dart';
import 'features/notificaciones/presentation/bloc/notificacion_event.dart';

void main() {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://huellitas-backend-xekn.onrender.com'),
  );

  final authDataSource = AuthRemoteDataSourceImpl(dio);
  final authRepository = AuthRepositoryImpl(authDataSource);
  final tokenStorage = TokenStorageService();
  final completarPerfilDataSource = CompletarPerfilRemoteDataSourceImpl(dio);
  final completarPerfilRepository = CompletarPerfilRepositoryImpl(
    completarPerfilDataSource,
  );
  final insigniaDataSource = InsigniaRemoteDataSourceImpl(dio);
  final insigniaRepository = InsigniaRepositoryImpl(insigniaDataSource);
  final getInsigniasUsuario = GetInsigniasUsuarioUseCase(insigniaRepository);

  final donacionDataSource = DonacionRemoteDataSourceImpl(dio);
  final donacionRepository = DonacionRepositoryImpl(donacionDataSource);

  final obtenerOrganizacionesUseCase = ObtenerOrganizacionesUseCase(
    donacionRepository,
  );
  final crearDonacionUseCase = CrearDonacionUseCase(donacionRepository);

  final tarjetaDataSource = TarjetaRemoteDataSourceImpl(dio);
  final tarjetaRepository = TarjetaRepositoryImpl(tarjetaDataSource);
  final obtenerTarjetasUseCase = ObtenerTarjetasUseCase(tarjetaRepository);
  final guardarTarjetaUseCase = GuardarTarjetaUseCase(tarjetaRepository);
  final eliminarTarjetaUseCase = EliminarTarjetaUseCase(tarjetaRepository);

  final actualizarTarjetaUseCase = ActualizarTarjetaUseCase(tarjetaRepository);
  final establecerPredeterminadaUseCase = EstablecerPredeterminadaUseCase(
    tarjetaRepository,
  );
  final foroDataSource = ForoRemoteDataSourceImpl(dio);
  final foroRepository = ForoRepositoryImpl(foroDataSource);
  final reporteRepository = ReporteRepositoryImpl(
    ReporteRemoteDataSourceImpl(dio),
  );

  final historialDataSource = HistorialRemoteDataSourceImpl(dio);
  // para prueba del front de historial
  //final historialDataSource = HistorialRemoteDataSourceMock();
  final historialRepository = HistorialRepositoryImpl(historialDataSource);
  final obtenerHistorialDonacionesUseCase = ObtenerHistorialDonacionesUseCase(
    historialRepository,
  );

  // final notificacionDataSource = NotificacionRemoteDataSourceImpl(dio);
  // pruebas
  final notificacionDataSource = NotificacionRemoteDataSourceImpl(dio);
  final notificacionRepository = NotificacionRepositoryImpl(
    notificacionDataSource,
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.obtenerToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryImpl>.value(value: authRepository),
        RepositoryProvider<TokenStorageService>.value(value: tokenStorage),
        RepositoryProvider<CompletarPerfilRepositoryImpl>.value(
          value: completarPerfilRepository,
        ),
        RepositoryProvider<Dio>.value(value: dio),
        RepositoryProvider<InsigniaRepositoryImpl>.value(
          value: insigniaRepository,
        ),
        RepositoryProvider<ForoRepository>.value(value: foroRepository),
        RepositoryProvider<ReporteRepository>.value(value: reporteRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              registerUseCase: RegisterUseCase(
                context.read<AuthRepositoryImpl>(),
              ),
              loginUseCase: LoginUseCase(context.read<AuthRepositoryImpl>()),
              enviarCodigoUseCase: EnviarCodigoUseCase(
                context.read<AuthRepositoryImpl>(),
              ),
              confirmarCodigoUseCase: ConfirmarCodigoUseCase(
                context.read<AuthRepositoryImpl>(),
              ),
              tokenStorage: tokenStorage,
            ),
          ),
          BlocProvider(
            create: (context) => CompletarPerfilBloc(
              repository: context.read<CompletarPerfilRepositoryImpl>(),
            ),
          ),
          BlocProvider(create: (_) => VerificacionCubit()),
          BlocProvider(
            create: (context) =>
                InsigniaBloc(getInsignias: getInsigniasUsuario),
          ),
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(
            create: (context) => DonacionBloc(
              obtenerOrganizaciones: obtenerOrganizacionesUseCase,
              crearDonacion: crearDonacionUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => TarjetaBloc(
              obtenerTarjetas: obtenerTarjetasUseCase,
              guardarTarjeta: guardarTarjetaUseCase,
              eliminarTarjeta: eliminarTarjetaUseCase,
              actualizarTarjeta: actualizarTarjetaUseCase,
              establecerPredeterminada: establecerPredeterminadaUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => HistorialBloc(
              obtenerDonaciones: obtenerHistorialDonacionesUseCase,
              obtenerOrganizaciones:
                  obtenerOrganizacionesUseCase, // ← ya existe en tu main
            ),
          ),
          BlocProvider(
            create: (context) =>
                NotificacionBloc(repository: notificacionRepository)
                  ..add(CargarNotificaciones()),
          ),
        ],
        child: const HuellitasApp(),
      ),
    ),
  );
}
