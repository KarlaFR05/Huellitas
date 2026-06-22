import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/registro_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';


void main() {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.18.11:8000',
  ));

  final authDataSource = AuthRemoteDataSourceImpl(dio);
  final authRepository = AuthRepositoryImpl(authDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryImpl>.value(
          value: authRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              registerUseCase:
                  RegisterUseCase(context.read<AuthRepositoryImpl>()),
              loginUseCase:
                  LoginUseCase(context.read<AuthRepositoryImpl>()),
            ),
          ),
        ],
        child: const HuellitasApp(),
      ),
    ),
  );
}