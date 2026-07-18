import 'package:flutter/material.dart';

import 'ayuda/preguntas_frecuentes_screen.dart';
import 'ayuda/contacto_screen.dart';
import 'ayuda/acerca_huellitas_screen.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayuda"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Preguntas frecuentes"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PreguntasFrecuentesScreen(),
                ),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text("Contacto"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactoScreen(),
                ),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Acerca de Huellitas"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AcercaHuellitasScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}