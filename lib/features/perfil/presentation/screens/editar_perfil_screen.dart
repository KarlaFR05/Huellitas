import 'package:flutter/material.dart';

class EditarPerfilScreen extends StatelessWidget {
  const EditarPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage(
                'assets/images/perfil.png',
              ),
            ),

            const SizedBox(height: 25),

            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                labelText: 'Apellidos',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Guardar cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}