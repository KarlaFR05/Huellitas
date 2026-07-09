import 'package:flutter/material.dart';
import '../../../../../styles/constantes/app_colors.dart';
import '../../domain/entities/categoria_insignia.dart';

class CategoriaSelector extends StatelessWidget {
  final CategoriaInsignia? categoriaSeleccionada;
  final Function(CategoriaInsignia?) onCategoriaSeleccionada;

  const CategoriaSelector({
    super.key,
    required this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    final categorias = [
      {'label': 'Todas', 'icon': Icons.apps_outlined, 'categoria': null},
      {
        'label': 'Reportes',
        'icon': Icons.report_outlined,
        'categoria': CategoriaInsignia.reporte
      },
      {
        'label': 'Donaciones',
        'icon': Icons.attach_money,
        'categoria': CategoriaInsignia.donacion
      },
      {
        'label': 'Rescates',
        'icon': Icons.favorite_outline,
        'categoria': CategoriaInsignia.rescate
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categorias.map((cat) {
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;
          final categoria = cat['categoria'] as CategoriaInsignia?;
          final isSelected = categoriaSeleccionada == categoria;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CategoriaChip(
              label: label,
              icon: icon,
              isSelected: isSelected,
              onTap: () {
                print('Seleccionando categoría: $label');
                onCategoriaSeleccionada(categoria);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoriaChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}