import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Inicio Sesión',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 30),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
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

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.go('/home');
            },
            child: const Text(
              'Iniciar Sesión',
            ),
          ),
        ),

        const SizedBox(height: 10),

        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text(
            'Crear Cuenta',
          ),
        ),
      ],
    );
  }
}