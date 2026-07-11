import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../styles/constantes/app_colors.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';

class InsigniaDetalleScreen extends StatelessWidget {
  final Insignia insignia;

  const InsigniaDetalleScreen({
    super.key,
    required this.insignia,
  });

  // Formatear fecha en español sin necesidad de intl
  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Insignia',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: insignia.imagenUrl != null && insignia.imagenUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        insignia.imagenUrl!,
                        fit: BoxFit.contain,  // ← CAMBIO: contain en lugar de cover
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackIcon();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    )
                  : _buildFallbackIcon(),
            ),
            
            const SizedBox(height: 32),
            
            // Nombre de la insignia
            Text(
              insignia.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Nivel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nivel ${insignia.nivel}',
                style: const TextStyle(
                  color: AppColors.primary,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _obtenerMensaje(insignia),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Fecha de obtención
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Obtenida el',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fechaFormateada,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
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
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _buildFallbackIcon() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.emoji_events,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}