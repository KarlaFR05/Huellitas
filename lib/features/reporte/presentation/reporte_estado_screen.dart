import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_colors.dart';
import '../../home/presentation/widgets/bottom_bar.dart';
import '../domain/entities/fase_reporte.dart';
import 'bloc/reporte_estado_bloc.dart';
import 'bloc/reporte_estado_state.dart';
import 'bloc/reporte_estado_event.dart'; 
import 'reporte_detalle_screen.dart';
import 'actualizar_estado_screen.dart';

class ReporteEstadoScreen extends StatelessWidget {
  final int reporteId;

  const ReporteEstadoScreen({super.key, required this.reporteId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => context.read<ReporteEstadoBloc>()
        ..add(CargarEstadoReporte(reporteId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Reporte',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ReporteEstadoBloc, ReporteEstadoState>(
          builder: (context, state) {
            if (state is ReporteEstadoLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ReporteEstadoError) {
              return Center(child: Text(state.message));
            }
            if (state is ReporteEstadoLoaded) {
              return _buildContenido(context, state.reporte);
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const BottomBarWidget(currentIndex: 0),
      ),
    );
  }

  Widget _buildContenido(BuildContext context, reporte) {
    final fases = FaseReporte.values;
    final faseActualIndex = fases.indexOf(reporte.faseActual);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de fases con chevrón
          _buildFasesIndicator(fases, faseActualIndex),
          const SizedBox(height: 32),

          // Nivel de urgencia
          _buildInfoRow('Nivel de urgencia', reporte.nivelUrgencia,
              icon: Icons.warning_amber_rounded,
              iconColor: _getColorUrgencia(reporte.nivelUrgencia)),

          const SizedBox(height: 16),

          // Tipo de reporte
          _buildInfoRow('Tipo de reporte', reporte.tipoReporte,
              icon: Icons.category_outlined),

          const SizedBox(height: 16),

          // Descripción
          _buildInfoRow('Descripción', reporte.descripcion,
              icon: Icons.description_outlined),

          const SizedBox(height: 16),

          // Ubicación
          _buildInfoRow('Ubicación', reporte.ubicacion,
              icon: Icons.location_on, iconColor: AppColors.primary),

          const SizedBox(height: 40),

          // Botones
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                context.push('/reporte-detalle', extra: reporte);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(55),
                ),
              ),
              child: const Text(
                'Ver más sobre el reporte',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                context.push('/actualizar-estado', extra: reporte);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(55),
                ),
              ),
              child: const Text(
                'Actualizar estado del reporte',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFasesIndicator(List<FaseReporte> fases, int faseActualIndex) {
    return SizedBox(
      height: 60,
      child: Row(
        children: fases.asMap().entries.map((entry) {
          final index = entry.key;
          final fase = entry.value;
          final esActual = index == faseActualIndex;
          final esAnterior = index < faseActualIndex;

          Color colorFondo;
          if (esActual) {
            if (index == 0) colorFondo = Colors.red;
            else if (index == 1) colorFondo = const Color.fromARGB(255, 255, 196, 0);
            else colorFondo = Colors.green;
          } else if (esAnterior) {
            colorFondo = Colors.grey.shade500;
          } else {
            colorFondo = Colors.grey.shade300;
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _ChevronStep(
                label: fase.label,
                color: colorFondo,
                isActive: esActual || esAnterior,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {IconData? icon, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorUrgencia(String urgencia) {
    switch (urgencia.toLowerCase()) {
      case 'baja':
        return Colors.yellow.shade700;
      case 'media':
        return Colors.orange;
      case 'alta':
        return Colors.red;
      case 'crítica':
        return const Color(0xFF800020);
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ChevronStep extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const _ChevronStep({
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _ChevronClipper(),
      child: Container(
        color: isActive ? color : Colors.grey.shade300,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronClipper extends CustomClipper<Path> {
  const _ChevronClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final chevronWidth = 12.0;
    final cornerRadius = 6.0;

    // Punto de inicio: esquina superior izquierda con ligero redondeo
    path.moveTo(cornerRadius, 0);
    
    // Línea superior hasta antes de la punta
    path.lineTo(size.width - chevronWidth, 0);
    
    // Punta derecha superior
    path.lineTo(size.width, size.height / 2);
    
    // Punta derecha inferior
    path.lineTo(size.width - chevronWidth, size.height);
    
    // Línea inferior hasta antes de la entrada
    path.lineTo(cornerRadius, size.height);
    
    // Esquina inferior izquierda redondeada
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    
    // Entrada en V hacia la izquierda (centro)
    path.lineTo(0, size.height / 2);
    
    // Salida de la entrada
    path.lineTo(0, cornerRadius);
    
    // Esquina superior izquierda redondeada
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}