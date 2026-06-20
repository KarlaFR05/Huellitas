import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordForm extends StatefulWidget {
  const PasswordForm({super.key});

  @override
  State<PasswordForm> createState() =>
      _PasswordFormState();
}

class _PasswordFormState
    extends State<PasswordForm> {

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            context.go('/home');
          },
          child: const Text(
            'Crear Cuenta',
          ),
        ),
      ],
    );
  }
}