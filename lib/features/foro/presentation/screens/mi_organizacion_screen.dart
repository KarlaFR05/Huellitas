import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/organizacion_foro_datasource.dart';
import '../../data/repositories/organizacion_foro_repository_impl.dart';
import '../../domain/entities/organizacion_foro.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import '../../domain/entities/publicacion.dart';
import '../bloc/foro_bloc.dart';
import '../bloc/foro_event.dart';
import '../bloc/foro_state.dart';
import '../widgets/publicacion_card.dart';
import 'comentarios_screen.dart';
import 'crear_publicacion_screen.dart';
import 'organizacion_perfil_screen.dart';

class MiOrganizacionScreen extends StatelessWidget {
  const MiOrganizacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ForoBloc(repository: context.read<ForoRepository>())
            ..add(const ForoFeedSolicitado(recargar: true)),
      child: const _MiOrganizacionView(),
    );
  }
}

class _MiOrganizacionView extends StatefulWidget {
  const _MiOrganizacionView();

  @override
  State<_MiOrganizacionView> createState() => _MiOrganizacionViewState();
}

class _MiOrganizacionViewState extends State<_MiOrganizacionView> {
  late Future<OrganizacionForo?> _future;
  int? _usuarioId;
  int _refreshKey = 0;
  
  final Map<int, OrganizacionForo> _mapaOrgs = {};
  bool _orgsCargadas = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      _usuarioId = (authState.data as Usuario).usuarioIdPk;
    }
    _future = _cargarOrganizacion();
  }

  Future<OrganizacionForo?> _cargarOrganizacion() async {
    final dio = context.read<Dio>();
    return OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(dio),
    ).obtenerMiOrganizacion();
  }

  void _recargar() {
    setState(() {
      _refreshKey++;
      _future = _cargarOrganizacion();
    });
  }

  void _cargarOrganizacionesDePublicaciones(List<Publicacion> publicaciones) {
    if (_orgsCargadas) return;

    final usuarioIds = publicaciones
        .where((p) => p.usuarioId != null)
        .map((p) => p.usuarioId!)
        .toSet()
        .toList();

    if (usuarioIds.isEmpty) {
      _orgsCargadas = true;
      return;
    }

    final dio = context.read<Dio>();
    OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(dio),
    )
        .obtenerOrganizacionesVerificadas()
        .then((orgs) {
      if (!mounted) return;
      final mapa = <int, OrganizacionForo>{};
      for (final org in orgs) {
        mapa[org.usuarioId] = org;
      }
      setState(() {
        _mapaOrgs.addAll(mapa);
        _orgsCargadas = true;
      });
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _orgsCargadas = true;
        });
      }
    });
  }
  Future<void> _crearPublicacion(BuildContext context, int organizacionId) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()),
    );
    if (resultado == null || !context.mounted) return;

    final solicitud = CrearPublicacionSolicitud(
      titulo: resultado['titulo'] as String,
      contenido: resultado['contenido'] as String,
      categoria: resultado['categoria'] as CategoriaPublicacion,
      organizacionId: organizacionId, 
      imagenLocalPath: (resultado['imagen'] as dynamic)?.path as String?,
    );
    context.read<ForoBloc>().add(ForoPublicacionCreada(solicitud));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<OrganizacionForo?>(
      key: ValueKey(_refreshKey), 
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final organizacion = snapshot.data;
        if (organizacion == null) {
          return const Center(
            child: Text('Aún no tienes una organización registrada.'),
          );
        }

        return BlocBuilder<ForoBloc, ForoState>(
          builder: (context, state) {
            final publicaciones = state.publicaciones
                .where((p) => p.usuarioId == organizacion.usuarioId)
                .toList();

            if (publicaciones.isNotEmpty && !_orgsCargadas) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _cargarOrganizacionesDePublicaciones(publicaciones);
              });
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: .45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrganizacionPerfilScreen(
                              organizacion: organizacion,
                              publicaciones: publicaciones,
                            ),
                          ),
                        ).then((_) => _recargar()),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: colors.primaryContainer,
                              backgroundImage: organizacion.logoUrl.isNotEmpty
                                  ? NetworkImage(organizacion.logoUrl)
                                  : null,
                              child: organizacion.logoUrl.isEmpty
                                  ? Icon(Icons.pets_rounded, color: colors.primary)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          organizacion.nombre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const OrganizacionVerificadaBadge(size: 18),
                                    ],
                                  ),
                                  Text(
                                    '${organizacion.cantidadSeguidores} seguidores',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Publicaciones de mi organización',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Aquí puedes ver y administrar las publicaciones realizadas',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _crearPublicacion(context, organizacion.id),
                            icon: const Icon(Icons.edit_square, size: 18),
                            label: const Text('Publicar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (state.status == ForoStatus.cargando && publicaciones.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (publicaciones.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Aún no hay publicaciones de tu organización.'),
                    ),
                  )
                else
                  for (final publicacion in publicaciones)
                    _PublicacionConOrg(
                      publicacion: publicacion,
                      mapaOrgs: _mapaOrgs,
                      usuarioId: _usuarioId,
                      onMeGusta: () => context.read<ForoBloc>().add(
                        ForoMeGustaCambiado(publicacion.id),
                      ),
                      onComentarios: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComentariosScreen(
                            publicacion: publicacion,
                          ),
                        ),
                      ),
                      onEditar: publicacion.usuarioId == _usuarioId
                          ? () {}
                          : null,
                      onEliminar: publicacion.usuarioId == _usuarioId
                          ? () {
                              context.read<ForoBloc>().add(
                                ForoPublicacionEliminada(publicacion.id),
                              );
                            }
                          : null,
                    ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PublicacionConOrg extends StatelessWidget {
  final Publicacion publicacion;
  final Map<int, OrganizacionForo> mapaOrgs;
  final int? usuarioId;
  final VoidCallback onMeGusta;
  final VoidCallback onComentarios;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const _PublicacionConOrg({
    required this.publicacion,
    required this.mapaOrgs,
    required this.usuarioId,
    required this.onMeGusta,
    required this.onComentarios,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final org = publicacion.usuarioId != null
        ? mapaOrgs[publicacion.usuarioId]
        : null;
    final esOrg = org != null;
    
    final publicacionAMostrar = esOrg && org!.nombre.isNotEmpty
        ? publicacion.copyWith(
            nombreUsuario: org.nombre,
            fotoUsuarioUrl: org.logoUrl.isNotEmpty
                ? org.logoUrl
                : publicacion.fotoUsuarioUrl,
          )
        : publicacion;

    return PublicacionCard(
      publicacion: publicacionAMostrar,
      avatarUrl: publicacionAMostrar.fotoUsuarioUrl,
      autorVerificado: esOrg,
      onMeGusta: onMeGusta,
      onComentarios: onComentarios,
      onEditar: onEditar,
      onEliminar: onEliminar,
    );
  }
}