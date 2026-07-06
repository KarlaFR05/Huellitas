import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_colors.dart';
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
          // Indicador de fases
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
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.push('/reporte-detalle', extra: reporte);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.push('/actualizar-estado', extra: reporte);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    return Row(
      children: fases.asMap().entries.map((entry) {
        final index = entry.key;
        final fase = entry.value;
        final esActual = index == faseActualIndex;
        final esAnterior = index < faseActualIndex;

        Color colorFondo;
        if (esActual) {
          if (index == 0) colorFondo = Colors.red;
          else if (index == 1) colorFondo = Colors.orange;
          else colorFondo = Colors.green;
        } else if (esAnterior) {
          colorFondo = Colors.grey.shade300;
        } else {
          colorFondo = Colors.grey.shade200;
        }

        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              fase.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: esActual ? Colors.white : Colors.grey.shade700,
                fontSize: 11,
                fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
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