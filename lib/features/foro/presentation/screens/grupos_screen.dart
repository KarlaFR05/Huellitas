import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../../../core/storage/organizaciones_seguidas_storage.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
import '../../data/datasources/organizacion_foro_datasource.dart';
import '../../data/repositories/organizacion_foro_repository_impl.dart';
import '../../domain/entities/organizacion_foro.dart';
import '../widgets/organizacion_card.dart';
import 'organizacion_perfil_screen.dart';

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
    Navigator.push<Grupo>(
      context,
      MaterialPageRoute(builder: (_) => GrupoDetalleScreen(grupo: grupo)),
    ).then((resultado) {
      if (!context.mounted) return;
      if (resultado?.estado == EstadoGrupo.eliminado) {
        context.read<GruposBloc>().add(GrupoEliminadoLocalmente(grupo.id));
        return;
      }
      context.read<GruposBloc>()
        ..add(const GruposSolicitados())
        ..add(const MisGruposSolicitados());
    });
  }

  void _membresia(BuildContext context, Grupo grupo) {
    if (grupo.esMiembro) return;
    final bloc = context.read<GruposBloc>();
    if (grupo.solicitudPendiente) {
      bloc.add(SolicitudIngresoCancelada(grupo.id));
    } else if (!grupo.esMiembro &&
        grupo.privacidad == PrivacidadGrupo.privado) {
      bloc.add(SolicitudIngresoEnviada(grupo.id));
    } else {
      bloc.add(MembresiaGrupoCambiada(grupoId: grupo.id, unirse: true));
    }
  }

  Future<void> _salirDelGrupo(BuildContext context, Grupo grupo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Salir del grupo'),
        content: Text('¿Quieres salir de ${grupo.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      context.read<GruposBloc>().add(
        MembresiaGrupoCambiada(grupoId: grupo.id, unirse: false),
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
          final misGruposPorId = <int, Grupo>{
            for (final grupo in state.misGrupos) grupo.id: grupo,
          };
          final idsMisGrupos = misGruposPorId.keys.toSet();
          final descubrirPorId = <int, Grupo>{
            for (final grupo in state.grupos)
              if (!idsMisGrupos.contains(grupo.id) && !grupo.esMiembro)
                grupo.id: grupo,
          };
          final misGrupos = misGruposPorId.values.toList();
          final descubrir = descubrirPorId.values.toList();
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
                const _OrganizacionesVerificadas(),

                if (misGrupos.isNotEmpty) ...[
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
                      itemCount: misGrupos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final grupo = misGrupos[index];
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
                    actualizando:
                        state.actualizandoGrupoId == descubrir[index].id,
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
                    const SizedBox(height: 2),
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

class _OrganizacionesVerificadas extends StatefulWidget {
  const _OrganizacionesVerificadas();

  @override
  State<_OrganizacionesVerificadas> createState() =>
      _OrganizacionesVerificadasState();
}

class _OrganizacionesVerificadasState
    extends State<_OrganizacionesVerificadas> {
  late final OrganizacionForoRepositoryImpl _repository;
  late Future<List<OrganizacionForo>> _future;
  final _seguimientoStorage = OrganizacionesSeguidasStorage();
  final Map<int, OrganizacionForo> _organizacionesActualizadas = {};
  int _usuarioId = 0;

  @override
  void initState() {
    super.initState();
    final dio = context.read<Dio>();
    _repository = OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(dio),
    );

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      _usuarioId = (authState.data as Usuario).usuarioIdPk;
    }

    _future = _cargarOrganizaciones();
  }

  Future<List<OrganizacionForo>> _cargarOrganizaciones() async {
    final organizaciones = await _repository.obtenerOrganizacionesVerificadas();

    Set<int> organizacionesSeguidas = <int>{};
    try {
      organizacionesSeguidas = await _seguimientoStorage.obtener(_usuarioId);
    } catch (_) {
      // La lista remota sigue disponible aunque falle el almacenamiento local.
    }

    return organizaciones.map((organizacion) {
      final siguiendo =
          organizacion.esSeguidor ||
          organizacionesSeguidas.contains(organizacion.id);
      return siguiendo == organizacion.esSeguidor
          ? organizacion
          : organizacion.copyWith(esSeguidor: siguiendo);
    }).toList();
  }

  Future<void> _toggleSeguir(OrganizacionForo organizacion) async {
    late final ResultadoSeguimientoOrganizacion resultado;
    try {
      resultado = await _repository.toggleSeguir(organizacion.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeDeError(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    var siguiendoConfirmado = resultado.siguiendo;
    var seguidoresConfirmados = resultado.cantidadSeguidores;
    if (siguiendoConfirmado == null) {
      try {
        final organizaciones = await _repository
            .obtenerOrganizacionesVerificadas();
        final actualizada = organizaciones
            .where((item) => item.id == organizacion.id)
            .firstOrNull;
        if (actualizada != null) {
          seguidoresConfirmados ??= actualizada.cantidadSeguidores;
          if (actualizada.cantidadSeguidores !=
              organizacion.cantidadSeguidores) {
            siguiendoConfirmado =
                actualizada.cantidadSeguidores >
                organizacion.cantidadSeguidores;
          }
        }
      } catch (_) {
        // La confirmacion es auxiliar; el POST ya fue exitoso.
      }
    }

    if (!mounted) return;
    final siguiendo = siguiendoConfirmado ?? !organizacion.esSeguidor;
    final seguidores =
        seguidoresConfirmados ??
        (organizacion.cantidadSeguidores + (siguiendo ? 1 : -1))
            .clamp(0, 1 << 31)
            .toInt();

    setState(() {
      _organizacionesActualizadas[organizacion.id] = organizacion.copyWith(
        esSeguidor: siguiendo,
        cantidadSeguidores: seguidores,
      );
    });

    try {
      await _seguimientoStorage.actualizar(
        usuarioId: _usuarioId,
        organizacionId: organizacion.id,
        siguiendo: siguiendo,
      );
    } catch (_) {
      // El seguimiento ya se guardo en el backend; no se revierte la interfaz.
    }
  }

  void _abrirPerfil(OrganizacionForo organizacion) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizacionPerfilScreen(
          organizacion: organizacion,
          onSeguimientoChanged: (organizacionActualizada) {
            if (!mounted) return;
            setState(() {
              _organizacionesActualizadas[organizacionActualizada.id] =
                  organizacionActualizada;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrganizacionForo>>(
      future: _future,
      builder: (context, snapshot) {
        final organizaciones = snapshot.data ?? [];
        if (organizaciones.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organizaciones verificadas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: organizaciones.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final organizacionBase = organizaciones[index];
                  final organizacion =
                      _organizacionesActualizadas[organizacionBase.id] ??
                      organizacionBase;
                  return OrganizacionCard(
                    key: ValueKey(organizacion.id),
                    organizacion: organizacion,
                    onTap: () => _abrirPerfil(organizacion),
                    onToggleSeguir: () => _toggleSeguir(organizacion),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
