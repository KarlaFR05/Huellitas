import 'package:flutter/material.dart';

class MontoOpcionCard extends StatelessWidget {
  final double monto;
  final bool esPersonalizado;
  final VoidCallback onTap;

  const MontoOpcionCard({
    super.key,
    required this.monto,
    this.esPersonalizado = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (esPersonalizado) ...[
              Icon(Icons.edit_outlined, size: 32, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                'Otra Cantidad',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                '\$${monto.toInt()}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
