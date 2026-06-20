import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          Image.asset(
            'assets/images/logoo.png',
            height: 180,
          ),

          const SizedBox(height: 24),

          const Text(
            'Huellitas',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Acción real por vidas reales',
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Crear Cuenta'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.go('/register');
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Crear Cuenta'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}