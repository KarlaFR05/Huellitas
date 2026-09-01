import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  Future<void> _reiniciarAvisoDonaciones(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aviso_donaciones_simulado');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El aviso de donaciones se mostrará de nuevo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Configuración',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock_outline, color: colorScheme.primary),
            title: Text(
              'Cambiar contraseña',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push('/cambiar-contrasenia'),
          ),
          Divider(color: colorScheme.outlineVariant),
          ListTile(
            leading: Icon(
              Icons.dark_mode_outlined,
              color: colorScheme.primary,
            ),
            title: Text(
              'Tema',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push('/tema'),
          ),
          Divider(color: colorScheme.outlineVariant),
          ListTile(
            leading: Icon(
              Icons.volunteer_activism_outlined,
              color: colorScheme.primary,
            ),
            title: Text(
              'Reiniciar aviso de donaciones',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            subtitle: Text(
              'Volver a mostrar la advertencia de flujo simulado',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            trailing: Icon(Icons.refresh, color: colorScheme.onSurfaceVariant),
            onTap: () => _reiniciarAvisoDonaciones(context),
          ),
        ],
      ),
    );
  }
}
