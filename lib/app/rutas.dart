import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:huellitas/features/splash/presentation/screens/splash_screen.dart';
import 'package:huellitas/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:huellitas/features/auth/presentation/screens/login_screen.dart';
import 'package:huellitas/features/auth/presentation/screens/registro_screen.dart';
import 'package:huellitas/features/auth/presentation/screens/password_screen.dart';
import 'package:huellitas/features/home/presentation/screens/home_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/perfil_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/editar_perfil_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/mi_perfil_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/privacidad_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/configuracion_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/ayuda_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/tema_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/ayuda/preguntas_frecuentes_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/ayuda/contacto_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/ayuda/acerca_huellitas_screen.dart';
import 'package:huellitas/features/completar_registro/presentation/screens/completar_perfil_screen.dart';
import 'package:huellitas/features/completar_registro/presentation/screens/verificar_frente_screen.dart';
import 'package:huellitas/features/completar_registro/presentation/screens/verificar_reverso_screen.dart';
import 'package:huellitas/features/completar_registro/presentation/screens/selfie_screen.dart';
import 'package:huellitas/features/completar_registro/presentation/screens/perfil_completo_screen.dart';
import 'package:huellitas/features/perfil/presentation/screens/cambiar_contrasenia_screen.dart';

import 'package:huellitas/features/reporte/data/datasources/reporte_remote_datasource_impl.dart';
import 'package:huellitas/features/reporte/data/repositories/reporte_repository_impl.dart';
import 'package:huellitas/features/reporte/domain/usecases/create_reporte_usecase.dart';
import 'package:huellitas/features/reporte/presentation/report_success_screen.dart';
import 'package:huellitas/features/reporte/presentation/report_form_screen.dart';

import 'package:huellitas/features/reporte/data/datasources/catalog_remote_datasource_impl.dart';
import 'package:huellitas/features/reporte/data/repositories/catalog_repository_impl.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_animal_types.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_report_types.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_urgency_levels.dart';

import 'package:huellitas/features/reporte/presentation/bloc/reporte_bloc.dart';

// NUEVOS IMPORTS para seguimiento de reportes
import 'package:huellitas/features/reporte/data/datasources/reporte_estado_datasource_impl.dart';
import 'package:huellitas/features/reporte/data/repositories/reporte_estado_repository_impl.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_reporte_estado_usecase.dart';
import 'package:huellitas/features/reporte/domain/usecases/actualizar_estado_reporte_usecase.dart';
import 'package:huellitas/features/reporte/presentation/bloc/reporte_estado_bloc.dart';
import 'package:huellitas/features/reporte/presentation/reporte_estado_screen.dart';
import 'package:huellitas/features/reporte/presentation/reporte_detalle_screen.dart';
import 'package:huellitas/features/reporte/presentation/actualizar_estado_screen.dart';
import 'package:huellitas/features/reporte/presentation/actualizar_estado_success_screen.dart';
import 'package:huellitas/features/reporte/presentation/actualizar_estado_error_screen.dart';
import 'package:huellitas/features/reporte/domain/entities/reporte_estado.dart';
import 'package:huellitas/features/perfil/presentation/screens/seleccionar_foto_perfil_screen.dart';

import 'package:huellitas/features/insignias/data/datasources/insignia_remote_datasource_impl.dart';
import 'package:huellitas/features/insignias/data/repositories/insignia_repository_impl.dart';
import 'package:huellitas/features/insignias/domain/usecases/get_insignias_usuario_usecase.dart';
import 'package:huellitas/features/insignias/domain/entities/insignia.dart';
import 'package:huellitas/features/insignias/presentation/bloc/insignia_bloc.dart';
import 'package:huellitas/features/insignias/presentation/screens/insignias_screen.dart';
import 'package:huellitas/features/insignias/presentation/screens/insignia_detalle_screen.dart';

import 'package:huellitas/features/reporte/domain/usecases/tomar_reporte_usecase.dart';
import 'package:huellitas/features/foro/presentation/screens/foro_screen.dart';


import 'package:huellitas/features/donaciones/presentation/screens/donaciones_screen.dart';
import 'package:huellitas/features/donaciones/presentation/screens/seleccion_cantidad_screen.dart';
import 'package:huellitas/features/donaciones/presentation/screens/monto_personalizado_screen.dart';

import 'package:huellitas/features/donaciones/presentation/screens/confirmacion_donacion_screen.dart';
import 'package:huellitas/features/donaciones/presentation/screens/donacion_error_screen.dart';

import 'package:huellitas/features/donaciones/presentation/screens/seleccion_tarjeta_screen.dart';
import 'package:huellitas/features/donaciones/presentation/screens/agregar_tarjeta_screen.dart';
import 'package:huellitas/features/donaciones/domain/entities/tarjeta.dart';
import 'package:huellitas/features/perfil/presentation/screens/mis_tarjetas.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    GoRoute(
      path: '/password',
      builder: (context, state) => const PasswordScreen(),
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/report-success',
      builder: (context, state) => const ReportSuccessScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistroScreen(),
    ),

    GoRoute(path: '/perfil', builder: (context, state) => const PerfilScreen()),

    GoRoute(
      path: '/editar-perfil',
      builder: (context, state) => const EditarPerfilScreen(),
    ),

    GoRoute(
      path: '/mi-perfil',
      builder: (context, state) {
        final usuarioId = state.extra as int?;
        return MiPerfilScreen(usuarioId: usuarioId);
      },
    ),

    GoRoute(
      path: '/privacidad',
      builder: (context, state) => const PrivacidadScreen(),
    ),

    GoRoute(
      path: '/configuracion',
      builder: (context, state) => const ConfiguracionScreen(),
    ),

    GoRoute(path: '/ayuda', builder: (context, state) => const AyudaScreen()),

    GoRoute(
      path: '/completar-perfil',
      builder: (context, state) => const CompletarPerfilScreen(),
    ),

    GoRoute(
      path: '/cambiar-contrasenia',
      builder: (context, state) => const CambiarContraseniaScreen(),
    ),

    GoRoute(
      path: '/verificar-frente',
      builder: (context, state) => const VerificarFrenteScreen(),
    ),

    GoRoute(
      path: '/verificar-reverso',
      builder: (context, state) => const VerificarReversoScreen(),
    ),

    GoRoute(path: '/selfie', builder: (context, state) => const SelfieScreen()),

    GoRoute(
      path: '/perfil_completo',
      builder: (context, state) => const PerfilCompletoScreen(),
    ),

    GoRoute(
      path: '/seleccionar-foto-perfil',
      builder: (context, state) => const SeleccionarFotoPerfilScreen(),
    ),

    GoRoute(
      path: '/report-form',
      pageBuilder: (context, state) {
        final dio = context.read<Dio>();

        final reporteRepository = ReporteRepositoryImpl(
          ReporteRemoteDataSourceImpl(dio),
        );

        final catalogRepository = CatalogRepositoryImpl(
          CatalogRemoteDataSourceImpl(dio),
        );

        return MaterialPage(
          child: BlocProvider(
            create: (_) => ReporteBloc(
              crearReporte: CreateReporteUseCase(reporteRepository),
              getAnimalTypes: GetAnimalTypes(catalogRepository),
              getReportTypes: GetReportTypes(catalogRepository),
              getUrgencyLevels: GetUrgencyLevels(catalogRepository),
            ),
            child: const ReportFormScreen(),
          ),
        );
      },
    ),

    GoRoute(
      path: '/insignias',
      pageBuilder: (context, state) {
        final dio = Dio(
          BaseOptions(
            baseUrl: 'https://huellitas-backend-xekn.onrender.com',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        final dataSource = InsigniaRemoteDataSourceImpl(dio);
        final repository = InsigniaRepositoryImpl(dataSource);
        final useCase = GetInsigniasUsuarioUseCase(repository);

        return MaterialPage(
          child: BlocProvider(
            create: (_) => InsigniaBloc(getInsignias: useCase),
            child: const InsigniasScreen(),
          ),
        );
      },
    ),

    GoRoute(
      path: '/insignia-detalle',
      builder: (context, state) {
        final insignia = state.extra as Insignia;
        return InsigniaDetalleScreen(insignia: insignia);
      },
    ),

    GoRoute(
      path: '/reporte-estado/:id',
      pageBuilder: (context, state) {
        final reporteId = int.parse(state.pathParameters['id']!);

        final dio = context.read<Dio>();

        final dataSource = ReporteEstadoRemoteDataSourceImpl(dio);
        final repository = ReporteEstadoRepositoryImpl(dataSource);
        final getEstado = GetReporteEstadoUseCase(repository);
        final tomarReporte = TomarReporteUseCase(repository);
        final actualizarEstado = ActualizarEstadoReporteUseCase(repository);

        return MaterialPage(
          child: BlocProvider(
            create: (_) => ReporteEstadoBloc(
              getEstado: getEstado,
              tomarReporte: tomarReporte,
              actualizarEstado: actualizarEstado,
            ),
            child: ReporteEstadoScreen(reporteId: reporteId),
          ),
        );
      },
    ),

    GoRoute(
      path: '/reporte-detalle',
      builder: (context, state) {
        final reporte = state.extra as ReporteEstado;
        return ReporteDetalleScreen(reporte: reporte);
      },
    ),

    GoRoute(
      path: '/actualizar-estado',
      pageBuilder: (context, state) {
        final reporte = state.extra as ReporteEstado;

        final dio = context.read<Dio>();

        final dataSource = ReporteEstadoRemoteDataSourceImpl(dio);
        final repository = ReporteEstadoRepositoryImpl(dataSource);
        final getEstado = GetReporteEstadoUseCase(repository);
        final tomarReporte = TomarReporteUseCase(repository);
        final actualizarEstado = ActualizarEstadoReporteUseCase(repository);

        return MaterialPage(
          child: BlocProvider(
            create: (_) => ReporteEstadoBloc(
              getEstado: getEstado,
              tomarReporte: tomarReporte,
              actualizarEstado: actualizarEstado,
            ),
            child: ActualizarEstadoScreen(reporte: reporte),
          ),
        );
      },
    ),

    GoRoute(
      path: '/actualizar-estado-success',
      builder: (context, state) => const ActualizarEstadoSuccessScreen(),
    ),

    GoRoute(
      path: '/actualizar-estado-error',
      builder: (context, state) => const ActualizarEstadoErrorScreen(),
    ),

    GoRoute(path: '/tema', builder: (context, state) => const TemaScreen()),

    GoRoute(
      path: '/preguntas-frecuentes',
      builder: (context, state) => const PreguntasFrecuentesScreen(),
    ),

    GoRoute(
      path: '/acerca-huellitas',
      builder: (context, state) => const AcercaHuellitasScreen(),
    ),

    GoRoute(
      path: '/contacto',
      builder: (context, state) => const ContactoScreen(),
    ),

    GoRoute(path: '/foro', builder: (context, state) => const ForoScreen()),

    
    GoRoute(
      path: '/donaciones',
      name: 'donaciones',
      builder: (context, state) => const DonacionesScreen(),
    ),
    GoRoute(
      path: '/seleccion-cantidad',
      name: 'seleccion-cantidad',
      builder: (context, state) => const SeleccionCantidadScreen(),
    ),
    GoRoute(
      path: '/monto-personalizado',
      name: 'monto-personalizado',
      builder: (context, state) => const MontoPersonalizadoScreen(),
    ),
    GoRoute(
      path: '/confirmacion-donacion',
      name: 'confirmacion-donacion',
      builder: (context, state) => const ConfirmacionDonacionScreen(),
    ),
    GoRoute(
      path: '/donacion-error',
      name: 'donacion-error',
      builder: (context, state) => const DonacionErrorScreen(),
    ),
    GoRoute(
      path: '/seleccion-tarjeta',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SeleccionTarjetaScreen(
          monto: extra['monto'] as double,
          organizacionId: extra['organizacionId'] as int,
        );
      },
    ),
    GoRoute(
      path: '/agregar-tarjeta',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AgregarTarjetaScreen(
          monto: extra?['monto'] as double?,
          organizacionId: extra?['organizacionId'] as int?,
        );
      },
    ),
    GoRoute(
      path: '/editar-tarjeta',
      builder: (context, state) {
        final tarjeta = state.extra as Tarjeta;
        return AgregarTarjetaScreen(tarjeta: tarjeta);
      },
    ),
    GoRoute(
      path: '/mis-tarjetas',
      builder: (context, state) => const MisTarjetasScreen(),
    ),
  ],
);
