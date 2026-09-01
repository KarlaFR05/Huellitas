import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/registro_organizacion_form.dart';

class RegistroOrganizacionScreen extends StatelessWidget {
  const RegistroOrganizacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final datosUsuario =
        GoRouterState.of(context).extra as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/register'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: RegistroOrganizacionForm(
                datosUsuario: datosUsuario ?? {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}