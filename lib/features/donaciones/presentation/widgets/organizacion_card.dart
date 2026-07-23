import 'package:flutter/material.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../domain/entities/organizacion.dart';

class OrganizacionCard extends StatelessWidget {
  final Organizacion organizacion;
  final VoidCallback onTap;

  const OrganizacionCard({
    super.key,
    required this.organizacion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: organizacion.logoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        organizacion.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: 30,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 30,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                organizacion.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}