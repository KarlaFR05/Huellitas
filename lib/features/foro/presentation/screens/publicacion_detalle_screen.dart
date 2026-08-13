import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/publicacion.dart';
import '../../domain/repositories/foro_repository.dart';
import 'comentarios_screen.dart';

/// Se usa principalmente desde notificaciones.
class PublicacionDetalleScreen extends StatefulWidget {
  final int publicacionId;

  const PublicacionDetalleScreen({super.key, required this.publicacionId});

  @override
  State<PublicacionDetalleScreen> createState() =>
      _PublicacionDetalleScreenState();
}

class _PublicacionDetalleScreenState extends State<PublicacionDetalleScreen> {
  Publicacion? _publicacion;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPublicacion();
  }

  Future<void> _cargarPublicacion() async {
    try {
      final repository = context.read<ForoRepository>();
      final publicacion = await repository.obtenerPublicacion(
        widget.publicacionId,
      );
      if (mounted) {
        setState(() {
          _publicacion = publicacion;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar la publicación';
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_cargando) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _publicacion == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Publicación',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Publicación no encontrada',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    // Una vez cargada, muestra la publicación con sus comentarios
    return ComentariosScreen(publicacion: _publicacion!);
  }
}