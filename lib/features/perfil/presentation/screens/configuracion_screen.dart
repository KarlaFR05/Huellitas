import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Cambiar contraseña"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/cambiar-contrasenia'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text("Notificaciones"),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("Tema"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tema'),
          ),
        ],
      ),
    );
  }
}
