import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthBloc(),
      child: const HuellitasApp(),
    ),
  );
}