import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompletarPerfilScreen extends StatelessWidget {
  const CompletarPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completar Información"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Calle y Número",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              decoration: const InputDecoration(
                labelText: "Colonia",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              decoration: const InputDecoration(
                labelText: "Código Postal",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              decoration: const InputDecoration(
                labelText: "Ciudad",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              decoration: const InputDecoration(
                labelText: "Estado",
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  context.push('/verificar-frente');
                },
                child: const Text("Siguiente"),
              ),
            )
          ],
        ),
      ),
    );
  }
}