import 'package:flutter/material.dart';
import '../../../../../styles/constantes/app_colors.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: obtenida ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Opacity(
                opacity: obtenida ? 1.0 : 0.4,
                child: _buildInsigniaImage(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${insignia.nivel}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: obtenida ? AppColors.primary : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _getNombreCorto(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: obtenida
                    ? AppColors.textPrimary
                    : Colors.grey.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsigniaImage() {
    if (insignia.imagenUrl != null && insignia.imagenUrl!.isNotEmpty) {
      return Image.network(
        insignia.imagenUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          _getIconoPorCategoria(),
          size: 40,
          color: _getColorPorCategoria(),
        ),
      );
    }
    
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

  String _getNombreCorto() {
    switch (insignia.nivel) {
      case 1:
        return '1ra';
      case 3:
        return '3ra';
      case 5:
        return '5ta';
      case 10:
        return '10ma';
      default:
        return '${insignia.nivel}';
    }
  }
}