import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../styles/constantes/app_colors.dart';
import '../domain/entities/fase_reporte.dart';
import '../domain/entities/reporte_estado.dart';
import 'bloc/reporte_estado_bloc.dart';
import 'bloc/reporte_estado_event.dart';
import 'bloc/reporte_estado_state.dart';

class ActualizarEstadoScreen extends StatefulWidget {
  final ReporteEstado reporte;

  const ActualizarEstadoScreen({super.key, required this.reporte});

  @override
  State<ActualizarEstadoScreen> createState() => _ActualizarEstadoScreenState();
}

class _ActualizarEstadoScreenState extends State<ActualizarEstadoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _evidencia;
  int? _faseSeleccionada;

  List<FaseReporte> get _fasesDisponibles {
    final faseActualIndex = FaseReporte.values.indexOf(widget.reporte.faseActual);
    return FaseReporte.values.where((f) {
      final index = FaseReporte.values.indexOf(f);
      return index >= faseActualIndex;
    }).toList();
  }

  Future<void> _pickImage() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _evidencia = File(image.path));
      }
    } catch (e) {
      _showError('Error al seleccionar imagen');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Seleccionar imagen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Tomar fotografía'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Seleccionar de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _enviarActualizacion() {
    if (_faseSeleccionada == null) {
      _showError('Selecciona una fase');
      return;
    }
    if (_evidencia == null) {
      _showError('Debes subir una evidencia fotográfica');
      return;
    }

    context.read<ReporteEstadoBloc>().add(
          ActualizarEstado(
            reporteId: widget.reporte.reporteId,
            nuevaFaseId: _faseSeleccionada!,
            evidencia: _evidencia!,
          ),
        );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReporteEstadoBloc, ReporteEstadoState>(
      listener: (context, state) {
        if (state is ReporteEstadoActualizado) {
          context.go('/actualizar-estado-success');
        } else if (state is ReporteEstadoError) {
          context.go('/actualizar-estado-error');
        }
      },
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
            'Actualizar Estado De Reporte',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ReporteEstadoBloc, ReporteEstadoState>(
          builder: (context, state) {
            final cargando = state is ReporteEstadoActualizando;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿En qué fase se encuentra el reporte?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._fasesDisponibles.map((fase) {
                    final isSelected = _faseSeleccionada == fase.id;
                    return RadioListTile<int>(
                      value: fase.id,
                      groupValue: _faseSeleccionada,
                      onChanged: cargando
                          ? null
                          : (value) => setState(() => _faseSeleccionada = value),
                      activeColor: _getColorFase(fase),
                      title: Text(
                        fase.label,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    'Adjuntar evidencia',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Center(
                    child: GestureDetector(
                      onTap: cargando ? null : _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: _evidencia != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _evidencia!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Toca para agregar foto',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: cargando ? null : _enviarActualizacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Enviar actualización',
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
            );
          },
        ),
      ),
    );
  }

  Color _getColorFase(FaseReporte fase) {
    switch (fase) {
      case FaseReporte.requiereAtencion:
        return Colors.red;
      case FaseReporte.recibiendoAtencion:
        return const Color.fromARGB(255, 255, 247, 0);
      case FaseReporte.seEncuentraASalvo:
        return Colors.green;
    }
  }
}