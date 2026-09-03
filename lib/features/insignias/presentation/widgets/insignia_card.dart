import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';

class InsigniaCard extends StatelessWidget {
  final Insignia insignia;
  final bool obtenida;

  const InsigniaCard({
    super.key,
    required this.insignia,
    required this.obtenida,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: obtenida
          ? () {
              context.push('/insignia-detalle', extra: insignia);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: obtenida
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: obtenida ? 0.35 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2, // Más espacio para la imagen
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Opacity(
                    opacity: obtenida ? 1.0 : 0.5,
                    child: _buildInsigniaImage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                insignia.nombre,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: obtenida
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nivel ${insignia.nivel}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInsigniaImage() {
    if (insignia.imagenUrl != null && insignia.imagenUrl!.isNotEmpty) {
      return Image.network(
        insignia.imagenUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Icon(
      _getIconoPorCategoria(),
      size: 40,
      color: _getColorPorCategoria(),
    );
  }

  IconData _getIconoPorCategoria() {
    switch (insignia.categoria) {
      case CategoriaInsignia.rescate:
        return Icons.favorite;
      case CategoriaInsignia.donacion:
        return Icons.attach_money;
      case CategoriaInsignia.reporte:
        return Icons.report;
    }
  }

  Color _getColorPorCategoria() {
    switch (insignia.categoria) {
      case CategoriaInsignia.rescate:
        return Colors.red;
      case CategoriaInsignia.donacion:
        return Colors.amber;
      case CategoriaInsignia.reporte:
        return Colors.blue;
    }
  }
}
