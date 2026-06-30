import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text("Cambiar contraseña"),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text("Notificaciones"),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: Text("Tema"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}