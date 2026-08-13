import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    // Espera mínima para que se vea el splash (opcional, estético)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(VerificarSesionEvent());

    final estadoFinal = await authBloc.stream.firstWhere(
      (state) => state is! AuthLoading,
    );

    if (!mounted) return;

    if (estadoFinal is AuthSuccess) {
      context.go('/home');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/images/logoo.png', width: 240)),
    );
  }
}
