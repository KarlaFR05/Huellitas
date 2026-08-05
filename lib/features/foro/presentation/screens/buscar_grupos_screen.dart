import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/grupo.dart';
import '../../domain/repositories/foro_repository.dart';
import '../bloc/grupos_bloc.dart';
import '../widgets/grupo_card.dart';
import 'grupo_detalle_screen.dart';

class BuscarGruposScreen extends StatelessWidget {
  const BuscarGruposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GruposBloc(repository: context.read<ForoRepository>())
            ..add(const GruposSolicitados()),
      child: const _BuscarGruposView(),
    );
  }
}

class _BuscarGruposView extends StatefulWidget {
  const _BuscarGruposView();

  @override
  State<_BuscarGruposView> createState() => _BuscarGruposViewState();
}

class _BuscarGruposViewState extends State<_BuscarGruposView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _buscar(String texto) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<GruposBloc>().add(GruposSolicitados(busqueda: texto));
      }
    });
  }

  void _membresia(Grupo grupo) {
    final bloc = context.read<GruposBloc>();
    if (grupo.solicitudPendiente) {
      bloc.add(SolicitudIngresoCancelada(grupo.id));
    } else if (!grupo.esMiembro &&
        grupo.privacidad == PrivacidadGrupo.privado) {
      bloc.add(SolicitudIngresoEnviada(grupo.id));
    } else {
      bloc.add(
        MembresiaGrupoCambiada(grupoId: grupo.id, unirse: !grupo.esMiembro),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar grupos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _buscar,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    _controller.clear();
                    _buscar('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<GruposBloc, GruposState>(
              builder: (context, state) {
                if (state.status == GruposStatus.cargando &&
                    state.grupos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == GruposStatus.error &&
                    state.grupos.isEmpty) {
                  return const Center(
                    child: Text('No se pudieron buscar grupos.'),
                  );
                }
                if (state.grupos.isEmpty) {
                  return const Center(
                    child: Text('No encontramos grupos con ese nombre.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: state.grupos.length,
                  itemBuilder: (context, index) {
                    final grupo = state.grupos[index];
                    return GrupoCard(
                      grupo: grupo,
                      onAbrir: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GrupoDetalleScreen(grupo: grupo),
                        ),
                      ),
                      onCambiarMembresia: () => _membresia(grupo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
