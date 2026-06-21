import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PasswordForm extends StatefulWidget {
  const PasswordForm({super.key});

  @override
  State<PasswordForm> createState() =>
      _PasswordFormState();
}

class _PasswordFormState
    extends State<PasswordForm> {

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final args = GoRouterState.of(context).extra
        as Map<String, dynamic>?;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada exitosamente'),
            ),
          );
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Crear Contraseña',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: confirmController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText:
                      'Confirmar Contraseña',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirm =
                            !obscureConfirm;
                      });
                    },
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isLoading ? null : () {
                  if (passwordController.text !=
                      confirmController.text) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Las contraseñas no coinciden',
                        ),
                      ),
                    );
                    return;
                  }
                  if (args == null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error: Datos incompletos',
                        ),
                      ),
                    );
                    return;
                  }

                  context.read<AuthBloc>().add(
                    RegisterEvent(
                      correo: args['correo'],
                      password: passwordController.text,
                      nombre: args['nombre'],
                      apellidos: args['apellidos'],
                      numTelefono: args['telefono'],
                      fechaNacimiento:
                          args['fechaNacimiento'],
                    ),
                  );
                },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Crear Cuenta',
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}