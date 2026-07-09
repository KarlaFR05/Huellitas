import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/registro_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'core/storage/token_storage_service.dart';
import 'features/completar_registro/data/datasources/completar_perfil_remote_datasource.dart';
import 'features/completar_registro/data/repositories/completar_perfil_repository_impl.dart';
import 'features/completar_registro/presentation/bloc/completar_perfil_bloc.dart';
import 'core/verificacion/verificacion_cubit.dart';

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
        RepositoryProvider<CompletarPerfilRepositoryImpl>.value(
          value: completarPerfilRepository,
        ),
        RepositoryProvider<Dio>.value(value: dio),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              registerUseCase: RegisterUseCase(
                context.read<AuthRepositoryImpl>(),
              ),
              loginUseCase: LoginUseCase(context.read<AuthRepositoryImpl>()),
              tokenStorage: tokenStorage,
            ),
          ),
          BlocProvider(
            create: (context) => CompletarPerfilBloc(
              repository: context.read<CompletarPerfilRepositoryImpl>(),
            ),
          ),
          BlocProvider(create: (_) => VerificacionCubit()),
        ],
        child: const HuellitasApp(),
      ),
    ),
  );
}
