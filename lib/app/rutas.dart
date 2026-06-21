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

import 'package:huellitas/features/reporte/data/datasources/reporte_remote_datasource_impl.dart';
import 'package:huellitas/features/reporte/data/repositories/reporte_repository_impl.dart';
import 'package:huellitas/features/reporte/domain/usecases/create_reporte_usecase.dart';

import 'package:huellitas/features/reporte/presentation/bloc/reporte_event.dart';
import 'package:huellitas/features/reporte/data/datasources/catalog_remote_datasource_impl.dart';
import 'package:huellitas/features/reporte/data/repositories/catalog_repository_impl.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_animal_types.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_report_types.dart';
import 'package:huellitas/features/reporte/domain/usecases/get_urgency_levels.dart';

import 'package:huellitas/features/reporte/presentation/bloc/reporte_bloc.dart';
import 'package:huellitas/features/reporte/presentation/screens/report_form_screen.dart';

import 'package:huellitas/features/reporte/presentation/screens/report_success_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistroScreen(),
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

    GoRoute(
      path: '/report-form',
      pageBuilder: (context, state) {
        final dio = Dio(
          BaseOptions(
            baseUrl: 'http://192.168.1.68:8000',
            connectTimeout: const Duration(seconds: 7),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

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
  ],
);
