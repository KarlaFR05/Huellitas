import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PerfilCompletoScreen extends StatelessWidget {
  const PerfilCompletoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 120,
              ),

              const SizedBox(height: 25),

              const Text(
                "Tu información ha sido enviada con éxito. Espera la validación de Huellitas.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    context.go('/perfil');
                  },
                  child: const Text("Finalizar"),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}