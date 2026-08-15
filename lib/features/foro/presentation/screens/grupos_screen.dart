import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/grupo.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../bloc/grupos_bloc.dart';
import '../widgets/grupo_card.dart';
import '../widgets/grupo_imagen.dart';
import 'crear_grupo_screen.dart';
import 'buscar_grupos_screen.dart';
import 'grupo_detalle_screen.dart';

class GruposScreen extends StatelessWidget {
  const GruposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GruposBloc(repository: context.read<ForoRepository>())
            ..add(const GruposSolicitados())
            ..add(const MisGruposSolicitados()),
      child: const _GruposView(),
    );
  }
}

class _GruposView extends StatelessWidget {
  const _GruposView();

  Future<void> _crearGrupo(BuildContext context) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CrearGrupoScreen()),
    );
    if (resultado == null || !context.mounted) return;
    context.read<GruposBloc>().add(
      GrupoCreado(
        CrearGrupoSolicitud(
          nombre: resultado['nombre'] as String,
          descripcion: resultado['descripcion'] as String,
          fotoPerfilLocalPath: resultado['perfilPath'] as String?,
          fotoPortadaLocalPath: resultado['portadaPath'] as String?,
          privacidad: resultado['privacidad'] as PrivacidadGrupo,
        ),
      ),
    );
  }

  Future<void> _buscar(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const BuscarGruposScreen()),
    );
  }

  void _abrirGrupo(BuildContext context, Grupo grupo) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => GrupoDetalleScreen(grupo: grupo)),
    ).then((_) {
      if (!context.mounted) return;
      context.read<GruposBloc>()
        ..add(const GruposSolicitados())
        ..add(const MisGruposSolicitados());
    });
  }

  void _membresia(BuildContext context, Grupo grupo) {
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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<GruposBloc, GruposState>(
        listenWhen: (anterior, actual) =>
            anterior.mensajeError != actual.mensajeError,
        listener: (context, state) {
          if (state.mensajeError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.mensajeError!)));
          }
        },
        builder: (context, state) {
          if (state.status == GruposStatus.cargando && state.grupos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final descubrir = state.grupos
              .where((grupo) => !grupo.esMiembro)
              .toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<GruposBloc>()
                ..add(const GruposSolicitados())
                ..add(const MisGruposSolicitados());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                BottomBarWidget.contentClearance(context) + 88,
              ),
              children: [
                if (state.misGrupos.isNotEmpty) ...[
                  Text(
                    'Tus grupos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.misGrupos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final grupo = state.misGrupos[index];
                        return _GrupoCompacto(
                          grupo: grupo,
                          onTap: () => _abrirGrupo(context, grupo),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Descubre nuevos grupos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text('Comunidades que podrían interesarte'),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Buscar grupos',
                        onPressed: () => _buscar(context),
                        icon: Icon(Icons.search_rounded, color: colors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (descubrir.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: Text('No hay grupos para mostrar.')),
                  ),
                for (var index = 0; index < descubrir.length; index++)
                  GrupoCard(
                    grupo: descubrir[index],
                    onAbrir: () => _abrirGrupo(context, descubrir[index]),
                    onCambiarMembresia: () =>
                        _membresia(context, descubrir[index]),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: BottomBarWidget.contentClearance(context) + 18,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _crearGrupo(context),
          icon: const Icon(Icons.group_add_rounded),
          label: const Text('Crear grupo'),
        ),
      ),
    );
  }
}

class _GrupoCompacto extends StatelessWidget {
  const _GrupoCompacto({required this.grupo, required this.onTap});
  final Grupo grupo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              SizedBox(
                height: 82,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    portadaGrupo(grupo),
                    Positioned(
                      left: 10,
                      bottom: -20,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: CircleAvatar(
                          radius: 21,
                          backgroundImage: imagenPerfilGrupo(grupo),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 8),
                child: Column(
                  children: [
                    Text(
                      grupo.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text('${grupo.cantidadMiembros} miembros'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
