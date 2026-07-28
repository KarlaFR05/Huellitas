import 'package:flutter/material.dart';

class AcercaHuellitasScreen extends StatelessWidget {
  const AcercaHuellitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acerca de Huellitas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.pets, size: 45)),

            const SizedBox(height: 20),

            Text("Huellitas", style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 8),

            Text(
              "Versión 26.2.4",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            const Text(
              "Huellitas es una aplicación móvil diseñada para facilitar el reporte y seguimiento de animales en situación de riesgo mediante geolocalización y colaboración ciudadana.",
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            const ListTile(
              leading: Icon(Icons.flag),
              title: Text("Objetivo"),
              subtitle: Text(
                "Conectar ciudadanos, rescatistas y asociaciones para mejorar la atención y bienestar animal.",
              ),
            ),

            const Divider(),

            const ListTile(
              leading: Icon(Icons.school),
              title: Text("Desarrollado por"),
              subtitle: Text("Equipo 200OK"),
            ),

            const SizedBox(height: 30),

            Text(
              "© 2026 Huellitas\nTodos los derechos reservados.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
