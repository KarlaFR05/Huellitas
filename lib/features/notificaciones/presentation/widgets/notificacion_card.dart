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
    final contacto = _contactoCompartido();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notificacion.leida
            ? colorScheme.surfaceContainerLowest
            : color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: .45)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 68,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: .14),
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
                              fontSize: 16,
                              fontWeight: notificacion.leida
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notificacion.leida)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notificacion.mensaje,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contacto != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.contact_phone_rounded, size: 16, color: color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Contacto: $contacto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatearFecha(notificacion.creadaEn),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
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
      case 'nuevo_miembro_grupo':
      case 'miembro_grupo':
      case 'miembro_unido':
        return (Icons.person_add, Colors.purple);
      case 'aprobar_miembro':
        return (Icons.how_to_reg, Colors.teal);
      case 'adopcion_aceptada':
      case 'adopcion_aprobada':
        return (Icons.pets_rounded, Colors.green);
      case 'adopcion_no_seleccionada':
      case 'adopcion_rechazada':
        return (Icons.pets_outlined, colorScheme.onSurfaceVariant);
      default:
        return (Icons.notifications, colorScheme.primary);
    }
  }

  String? _contactoCompartido() {
    final data = notificacion.data;
    if (data == null) return null;
    for (final key in const [
      'contacto',
      'contacto_responsable',
      'medio_contacto',
    ]) {
      final valor = data[key]?.toString().trim();
      if (valor != null && valor.isNotEmpty) return valor;
    }
    return null;
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
