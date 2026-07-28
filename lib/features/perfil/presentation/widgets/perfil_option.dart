import 'package:flutter/material.dart';

class PerfilOption extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final VoidCallback? onTap;
  final bool mostrarFlecha;

  const PerfilOption({
    super.key,
    required this.icon,
    required this.titulo,
    this.onTap,
    this.mostrarFlecha = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: .15),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: mostrarFlecha
            ? Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
