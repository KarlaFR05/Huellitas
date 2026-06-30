import 'package:flutter/material.dart';

class InsigniasScreen extends StatelessWidget {
  const InsigniasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insignias = [
      {
        "titulo": "Primer reporte",
        "icono": Icons.pets,
        "descripcion": "Realizaste tu primer reporte."
      },
      {
        "titulo": "Rescatista",
        "icono": Icons.favorite,
        "descripcion": "5 reportes realizados."
      },
      {
        "titulo": "Protector",
        "icono": Icons.workspace_premium,
        "descripcion": "10 reportes realizados."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Insignias"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: insignias.length,
        itemBuilder: (context, index) {
          final item = insignias[index];

          return Card(
            child: ListTile(
              leading: Icon(
                item["icono"] as IconData,
                color: Colors.amber,
              ),
              title: Text(item["titulo"] as String),
              subtitle: Text(item["descripcion"] as String),
            ),
          );
        },
      ),
    );
  }
}