import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .55),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final vertical = constraints.maxWidth < 310 || textScale > 1.35;
          final opciones = CategoriaOrganizacion.values.map((categoria) {
            final isSelected = categoriaSeleccionada == categoria;
            final opcion = GestureDetector(
              onTap: () => onCategoriaSeleccionada(categoria),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 42),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  _getCategoriaLabel(categoria),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
            return vertical ? opcion : Expanded(child: opcion);
          }).toList();
          return vertical
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: opciones,
                )
              : Row(children: opciones);
        },
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
