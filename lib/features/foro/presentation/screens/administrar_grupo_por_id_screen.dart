import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/grupo.dart';
import '../../domain/repositories/foro_repository.dart';
import 'administrar_grupo_screen.dart';

class AdministrarGrupoPorIdScreen extends StatefulWidget {
  final int grupoId;

  const AdministrarGrupoPorIdScreen({super.key, required this.grupoId});

  @override
  State<AdministrarGrupoPorIdScreen> createState() =>
      _AdministrarGrupoPorIdScreenState();
}

class _AdministrarGrupoPorIdScreenState
    extends State<AdministrarGrupoPorIdScreen> {
  Grupo? _grupo;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarGrupo();
  }

  Future<void> _cargarGrupo() async {
    try {
      final repository = context.read<ForoRepository>();
      final grupo = await repository.obtenerGrupo(widget.grupoId);
      if (mounted) {
        setState(() {
          _grupo = grupo;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el grupo';
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

    if (_error != null || _grupo == null) {
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
            'Administrar grupo',
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
                _error ?? 'Grupo no encontrado',
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

    return AdministrarGrupoScreen(grupo: _grupo!);
  }
}