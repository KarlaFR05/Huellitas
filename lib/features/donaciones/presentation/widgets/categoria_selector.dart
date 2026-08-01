import 'package:flutter/material.dart';
import '../../../../styles/constantes/app_color.dart';
import '../../domain/entities/categoria_organizacion.dart';

class CategoriaSelector extends StatelessWidget {
  final CategoriaOrganizacion categoriaSeleccionada;
  final Function(CategoriaOrganizacion) onCategoriaSeleccionada;

  const CategoriaSelector({
    super.key,
    required this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: CategoriaOrganizacion.values.map((categoria) {
          final isSelected = categoriaSeleccionada == categoria;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCategoriaSeleccionada(categoria),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCategoriaLabel(categoria),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoriaLabel(CategoriaOrganizacion categoria) {
    switch (categoria) {
      case CategoriaOrganizacion.sinFinesLucro:
        return 'Sin Fines Lucro';
      case CategoriaOrganizacion.refugios:
        return 'Refugios';
      case CategoriaOrganizacion.gubernamentales:
        return 'Gubernamentales';
    }
  }
}