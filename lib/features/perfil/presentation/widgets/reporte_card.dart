import 'package:flutter/material.dart';

import '../../../reporte/domain/entities/reporte.dart';

class ReporteCard extends StatelessWidget {
  const ReporteCard({super.key, required this.reporte, this.onTap});

  final Reporte reporte;
  final VoidCallback? onTap;

  ({String texto, Color color}) get _estado {
    return switch (reporte.faseActualId) {
      3 => (texto: 'Resuelto', color: const Color(0xFF36B985)),
      2 => (texto: 'En seguimiento', color: const Color(0xFFFFB52E)),
      _ => (texto: 'En riesgo', color: const Color(0xFFFF5C63)),
    };
  }

  String get _titulo {
    if (reporte.descripcion.trim().isNotEmpty) return reporte.descripcion.trim();
    final animal = reporte.tipoAnimalId == 2 ? 'Gato' : 'Perro';
    return '$animal reportado';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final estado = _estado;
    return SizedBox(
      width: 252,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(right: 14, bottom: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _ReporteImagen(url: reporte.evidencia),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: estado.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado.texto,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 18, color: colors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reporte.ubicacion.isEmpty ? 'Ubicación no disponible' : reporte.ubicacion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReporteImagen extends StatelessWidget {
  const _ReporteImagen({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 158,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.pets_rounded, size: 54, color: Theme.of(context).colorScheme.primary),
    );
    if (url.trim().isEmpty) return placeholder;
    return Image.network(
      url,
      height: 158,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
