import 'package:flutter/material.dart';
import '../../domain/entities/notificacion.dart';

class NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback onTap;

  const NotificacionCard({
    super.key,
    required this.notificacion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icono, color) = _getIconoYColor(notificacion.tipo, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notificacion.leida ? colorScheme.surface : colorScheme.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notificacion.leida)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notificacion.mensaje,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatearFecha(notificacion.creadaEn),
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
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

  (IconData, Color) _getIconoYColor(String tipo, ColorScheme colorScheme) {
    switch (tipo) {
      case 'reporte_tomado':
        return (Icons.volunteer_activism, Colors.green);
      case 'reporte_cercano':
        return (Icons.location_on, Colors.orange);
      case 'donacion':
        return (Icons.favorite, Colors.pink);
      case 'reporte_exitoso':
        return (Icons.check_circle, Colors.green);
      case 'reaccion':
        return (Icons.favorite_border, Colors.red);
      case 'comentario':
        return (Icons.comment, Colors.blue);
      case 'nuevo_miembro':
        return (Icons.person_add, Colors.purple);
      case 'aprobar_miembro':
        return (Icons.how_to_reg, Colors.teal);
      default:
        return (Icons.notifications, colorScheme.primary);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}