import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../styles/constantes/app_colors.dart';
import '../domain/entities/reporte_estado.dart';

class ReporteDetalleScreen extends StatelessWidget {
  final ReporteEstado reporte;

  const ReporteDetalleScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
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
          'Reporte',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Tipo de animal', reporte.tipoAnimal),
            const SizedBox(height: 16),
            _buildField('Raza', reporte.raza),
            const SizedBox(height: 16),
            _buildField('Tamaño', reporte.tamano),
            const SizedBox(height: 24),
            const Text(
              'Evidencia',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _buildEvidencia(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidencia() {
    if (reporte.evidenciaUrl.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported,
              color: AppColors.textSecondary, size: 48),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(reporte.evidenciaUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}