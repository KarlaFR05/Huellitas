import 'package:flutter/material.dart';
import '../../../../styles/constantes/app_color.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (esPersonalizado) ...[
              Icon(
                Icons.edit_outlined,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              const Text(
                'Otra Cantidad',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                '\$${monto.toInt()}',
                style: TextStyle(
                  color: AppColors.primary,
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