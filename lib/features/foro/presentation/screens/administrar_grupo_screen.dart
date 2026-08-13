import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/avatar_helper.dart';
import '../../domain/entities/grupo.dart';
import '../../domain/entities/membresia_grupo.dart';
import '../../domain/repositories/foro_repository.dart';
import '../bloc/grupos_bloc.dart';

class AdministrarGrupoScreen extends StatelessWidget {
  const AdministrarGrupoScreen({super.key, required this.grupo});
  final Grupo grupo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GruposBloc(repository: context.read<ForoRepository>())
          ..add(MiembrosGrupoSolicitados(grupo.id));
        if (grupo.privacidad == PrivacidadGrupo.privado) {
          bloc.add(SolicitudesIngresoSolicitadas(grupo.id));
        }
        return bloc;
      },
      child: _AdministrarGrupoView(grupo: grupo),
    );
  }
}

class _AdministrarGrupoView extends StatelessWidget {
  const _AdministrarGrupoView({required this.grupo});
  final Grupo grupo;

  @override
  Widget build(BuildContext context) {
    final requiereSolicitudes = grupo.privacidad == PrivacidadGrupo.privado;
    return DefaultTabController(
      length: requiereSolicitudes ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrar grupo'),
          bottom: requiereSolicitudes
              ? const TabBar(
                  tabs: [
                    Tab(text: 'Solicitudes'),
                    Tab(text: 'Miembros'),
                  ],
                )
              : null,
        ),
        body: BlocConsumer<GruposBloc, GruposState>(
          listener: (context, state) {
            if (state.mensajeError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.mensajeError!)));
            }
          },
          builder: (context, state) {
            if (!requiereSolicitudes) {
              if (state.cargandoAdministracion && state.miembrosGrupo.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return _MiembrosLista(
                grupoId: grupo.id,
                miembros: state.miembrosGrupo,
              );
            }
            return TabBarView(
              children: [
                if (state.cargandoAdministracion &&
                    state.solicitudesIngreso.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  _SolicitudesLista(
                    grupoId: grupo.id,
                    solicitudes: state.solicitudesIngreso,
                  ),
                if (state.cargandoAdministracion && state.miembrosGrupo.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  _MiembrosLista(
                    grupoId: grupo.id,
                    miembros: state.miembrosGrupo,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SolicitudesLista extends StatelessWidget {
  const _SolicitudesLista({required this.grupoId, required this.solicitudes});
  final int grupoId;
  final List<MembresiaGrupo> solicitudes;

  @override
  Widget build(BuildContext context) {
    if (solicitudes.isEmpty) {
      return const Center(child: Text('No hay solicitudes pendientes.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: solicitudes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final solicitud = solicitudes[index];
        return Card(
          child: ListTile(
            leading: _AvatarMiembro(membresia: solicitud),
            title: Text(solicitud.nombreUsuario ?? 'Usuario'),
            subtitle: const Text('Quiere unirse al grupo'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Rechazar',
                  onPressed: () => context.read<GruposBloc>().add(
                    SolicitudIngresoRespondida(
                      grupoId: grupoId,
                      usuarioId: solicitud.usuarioId,
                      aceptar: false,
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
                IconButton.filled(
                  tooltip: 'Aceptar',
                  onPressed: () => context.read<GruposBloc>().add(
                    SolicitudIngresoRespondida(
                      grupoId: grupoId,
                      usuarioId: solicitud.usuarioId,
                      aceptar: true,
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiembrosLista extends StatelessWidget {
  const _MiembrosLista({required this.grupoId, required this.miembros});
  final int grupoId;
  final List<MembresiaGrupo> miembros;

  @override
  Widget build(BuildContext context) {
    if (miembros.isEmpty) return const Center(child: Text('No hay miembros.'));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: miembros.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final miembro = miembros[index];
        return Card(
          child: ListTile(
            leading: _AvatarMiembro(membresia: miembro),
            title: Text(miembro.nombreUsuario ?? 'Usuario'),
            subtitle: Text(
              miembro.esAdministrador ? 'Administrador' : 'Miembro',
            ),
            trailing: miembro.esAdministrador
                ? null
                : IconButton(
                    tooltip: 'Eliminar miembro',
                    onPressed: () => _confirmarEliminar(context, miembro),
                    icon: Icon(
                      Icons.person_remove_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    MembresiaGrupo miembro,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Eliminar a ${miembro.nombreUsuario ?? 'este usuario'} del grupo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      context.read<GruposBloc>().add(
        MiembroGrupoEliminado(grupoId: grupoId, usuarioId: miembro.usuarioId),
      );
    }
  }
}

class _AvatarMiembro extends StatelessWidget {
  const _AvatarMiembro({required this.membresia});
  final MembresiaGrupo membresia;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: membresia.fotoUsuarioUrl == null
          ? null
          : avatarProvider(membresia.fotoUsuarioUrl),
      child: membresia.fotoUsuarioUrl == null
          ? const Icon(Icons.person_outline_rounded)
          : null,
    );
  }
}
