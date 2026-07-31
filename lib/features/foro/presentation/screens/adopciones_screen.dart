import 'package:flutter/material.dart';

class AdopcionesScreen extends StatelessWidget {
  const AdopcionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_rounded, size: 90, color: colors.primary),
            const SizedBox(height: 24),
            Text(
              'Adopciones',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Muy pronto podrás encontrar animales que buscan un hogar responsable.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Chip(
              avatar: const Icon(Icons.construction_rounded, size: 18),
              label: const Text('Próximamente'),
            ),
          ],
        ),
      ),
    );
  }
}
