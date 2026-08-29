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
  late final Future<OrganizacionForo?> _future;
  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      _usuarioId = (authState.data as Usuario).usuarioIdPk;
    }
    
    final dio = context.read<Dio>();
    _future = OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(dio),
    ).obtenerMiOrganizacion();
  }

  Future<void> _crearPublicacion(BuildContext context) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()),
    );
    if (resultado == null || !context.mounted) return;

    final solicitud = CrearPublicacionSolicitud(
      titulo: resultado['titulo'] as String,
      contenido: resultado['contenido'] as String,
      categoria: resultado['categoria'] as CategoriaPublicacion,
      imagenLocalPath: (resultado['imagen'] as dynamic)?.path as String?,
    );
    context.read<ForoBloc>().add(ForoPublicacionCreada(solicitud));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<OrganizacionForo?>(
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
                        ),
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
                            onPressed: () => _crearPublicacion(context),
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
                    PublicacionCard(
                      publicacion: publicacion,
                      avatarUrl: publicacion.fotoUsuarioUrl,
                      autorVerificado: organizacion.verificada,
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
                    ),
              ],
            );
          },
        );
      },
    );
  }
}