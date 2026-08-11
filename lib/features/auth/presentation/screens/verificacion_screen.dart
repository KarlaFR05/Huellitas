import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/verificacion_form.dart';

class VerificacionScreen extends StatelessWidget {
  const VerificacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = GoRouterState.of(context).extra as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: VerificacionForm(
            correo: args['correo'] as String,
            datosRegistro: args,
          ),
        ),
      ),
    );
  }
}
