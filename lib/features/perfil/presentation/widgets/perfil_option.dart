import 'package:flutter/material.dart';
import '../../../../styles/constantes/app_colors.dart';

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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: .15),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: mostrarFlecha
            ? const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}