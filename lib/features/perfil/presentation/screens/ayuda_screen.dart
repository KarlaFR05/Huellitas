import 'package:flutter/material.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayuda"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text("Preguntas frecuentes"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text("Contacto"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Acerca de Huellitas"),
          ),
        ],
      ),
    );
  }
}