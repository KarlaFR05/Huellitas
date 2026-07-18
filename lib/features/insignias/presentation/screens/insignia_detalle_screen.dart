import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';

class InsigniaDetalleScreen extends StatelessWidget {
  final Insignia insignia;

  const InsigniaDetalleScreen({super.key, required this.insignia});

  // Formatear fecha en español sin necesidad de intl
  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  String _obtenerMensaje(Insignia insignia) {
    switch (insignia.nivel) {
      case 1:
        return '¡Realizaste tu primer ${_getAccion(insignia.categoria)}!';
      case 2:
        return '¡Realizaste 3 ${_getAccionPlural(insignia.categoria)}!';
      case 3:
        return '¡Realizaste 5 ${_getAccionPlural(insignia.categoria)}!';
      case 4:
        return '¡Realizaste 10 ${_getAccionPlural(insignia.categoria)}!';
      case 5:
        return '¡Realizaste 25 ${_getAccionPlural(insignia.categoria)}!';
      case 6:
        return '¡Realizaste 50 ${_getAccionPlural(insignia.categoria)}!';
      case 7:
        return '¡Realizaste 100 ${_getAccionPlural(insignia.categoria)}!';
      default:
        return '¡Felicitaciones!';
    }
  }

  String _getAccion(CategoriaInsignia categoria) {
    switch (categoria) {
      case CategoriaInsignia.rescate:
        return 'rescate';
      case CategoriaInsignia.donacion:
        return 'donación';
      case CategoriaInsignia.reporte:
        return 'reporte';
    }
  }

  String _getAccionPlural(CategoriaInsignia categoria) {
    switch (categoria) {
      case CategoriaInsignia.rescate:
        return 'rescates';
      case CategoriaInsignia.donacion:
        return 'donaciones';
      case CategoriaInsignia.reporte:
        return 'reportes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = insignia.fechaObtencion != null
        ? _formatearFecha(insignia.fechaObtencion!)
        : 'Fecha no disponible';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Insignia',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Medalla
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child:
                  insignia.imagenUrl != null && insignia.imagenUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        insignia.imagenUrl!,
                        fit: BoxFit
                            .contain, // ← CAMBIO: contain en lugar de cover
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackIcon(context);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    )
                  : _buildFallbackIcon(context),
            ),

            const SizedBox(height: 32),

            // Nombre de la insignia
            Text(
              insignia.nombre,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Nivel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nivel ${insignia.nivel}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Mensaje de logro
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _obtenerMensaje(insignia),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Fecha de obtención
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Obtenida el',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fechaFormateada,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 3),
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.emoji_events,
          size: 60,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
