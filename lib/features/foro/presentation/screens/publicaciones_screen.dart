import 'package:flutter/material.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; //añadiyo

import '../../domain/entities/publicacion.dart';
import '../../domain/entities/solicitudes_foro.dart'; //añadiyo
import '../../domain/repositories/foro_repository.dart'; //añadiyo
import '../bloc/foro_bloc.dart';
import '../bloc/foro_event.dart';
import '../bloc/foro_state.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../widgets/publicacion_card.dart';
import 'comentarios_screen.dart';
import 'crear_publicacion_screen.dart';

class PublicacionesScreen extends StatelessWidget {
  const PublicacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ForoBloc(repository: context.read<ForoRepository>())
            ..add(const ForoFeedSolicitado(recargar: true)),
      child: const _PublicacionesView(),
    );
  }
}

class _PublicacionesView extends StatelessWidget {
  const _PublicacionesView();

  static const _categorias =
      <
        ({
          IconData icon,
          String nombre,
          Color color,
          CategoriaPublicacion categoria,
        })
      >[
        (
          icon: Icons.pets_rounded,
          nombre: 'Adopción',
          color: Color(0xFFFF9F2F),
          categoria: CategoriaPublicacion.adopcion,
        ),
        (
          icon: Icons.vaccines_rounded,
          nombre: 'Vacunación',
          color: Color(0xFF3679D8),
          categoria: CategoriaPublicacion.vacunacion,
        ),
        (
          icon: Icons.health_and_safety_rounded,
          nombre: 'Salud',
          color: Color(0xFF27A56D),
          categoria: CategoriaPublicacion.salud,
        ),
        (
          icon: Icons.search_rounded,
          nombre: 'Extraviados',
          color: Color(0xFF7557D5),
          categoria: CategoriaPublicacion.extraviados,
        ),
        (
          icon: Icons.restaurant_rounded,
          nombre: 'Alimentación',
          color: Color(0xFF69B643),
          categoria: CategoriaPublicacion.alimentacion,
        ),
        (
          icon: Icons.school_rounded,
          nombre: 'Entrenamiento',
          color: Color(0xFF3971C8),
          categoria: CategoriaPublicacion.entrenamiento,
        ),
        (
          icon: Icons.favorite_rounded,
          nombre: 'Cuidado',
          color: Color(0xFFE65B70),
          categoria: CategoriaPublicacion.cuidado,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final usuarioId = authState is AuthSuccess && authState.data is Usuario
        ? (authState.data as Usuario).usuarioIdPk
        : null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ForoBloc, ForoState>(
        builder: (context, state) {
          final publicacionesVisibles = state.categoria == null
              ? state.publicaciones
              : state.publicaciones
                    .where((p) => p.categoria == state.categoria)
                    .toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ForoBloc>().add(
                const ForoFeedSolicitado(recargar: true),
              );
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
                _CategoriasCard(
                  categorias: _categorias,
                  seleccionada: state.categoria,
                  onSeleccionar: (categoria) {
                    context.read<ForoBloc>().add(
                      ForoFiltroCambiado(
                        state.categoria == categoria ? null : categoria,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                if (state.status == ForoStatus.cargando &&
                    state.publicaciones.isEmpty)
                  const _CargandoFeed(),
                if (state.status == ForoStatus.error &&
                    state.publicaciones.isEmpty)
                  _ErrorFeed(
                    mensaje: state.mensajeError ?? 'Error desconocido',
                  ),
                if (publicacionesVisibles.isEmpty &&
                    state.status == ForoStatus.exito)
                  _SinResultados(
                    onLimpiar: () => context.read<ForoBloc>().add(
                      const ForoFiltroCambiado(null),
                    ),
                  ),
                for (final publicacion in publicacionesVisibles)
                  PublicacionCard(
                    publicacion: publicacion,
                    avatarUrl: publicacion.fotoUsuarioUrl,
                    onMeGusta: () => context.read<ForoBloc>().add(
                      ForoMeGustaCambiado(publicacion.id),
                    ),
                    onComentarios: () =>
                        _abrirComentarios(context, publicacion),
                    onEditar: publicacion.usuarioId == usuarioId
                        ? () => _editarPublicacion(context, publicacion)
                        : null,
                  ),
                if (state.hayMas && state.status == ForoStatus.exito)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
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
          onPressed: () => _crearPublicacion(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Publicar'),
        ),
      ),
    );
  }

  Future<void> _abrirComentarios(
    BuildContext context,
    Publicacion publicacion,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ComentariosScreen(publicacion: publicacion),
      ),
    );
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

  Future<void> _editarPublicacion(
    BuildContext context,
    Publicacion publicacion,
  ) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearPublicacionScreen(publicacion: publicacion),
      ),
    );
    if (resultado == null || !context.mounted) return;
    context.read<ForoBloc>().add(
      ForoPublicacionEditada(
        publicacionId: publicacion.id,
        titulo: resultado['titulo'] as String,
        contenido: resultado['contenido'] as String,
        categoria: resultado['categoria'] as CategoriaPublicacion,
        imagenLocalPath: (resultado['imagen'] as dynamic)?.path as String?,
      ),
    );
  }
}

class _CargandoFeed extends StatelessWidget {
  const _CargandoFeed();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 42),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorFeed extends StatelessWidget {
  const _ErrorFeed({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 54,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar las publicaciones',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () => context.read<ForoBloc>().add(
              const ForoFeedSolicitado(recargar: true),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _CategoriasCard extends StatefulWidget {
  const _CategoriasCard({
    required this.categorias,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  final List<
    ({
      IconData icon,
      String nombre,
      Color color,
      CategoriaPublicacion categoria,
    })
  >
  categorias;
  final CategoriaPublicacion? seleccionada;
  final ValueChanged<CategoriaPublicacion> onSeleccionar;
  @override
  State<_CategoriasCard> createState() => _CategoriasCardState();
}

class _CategoriasCardState extends State<_CategoriasCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visibles = _expandido
        ? widget.categorias
        : widget.categorias.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explora por etiquetas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final ancho = (constraints.maxWidth - 6) / 2;
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final categoria in visibles)
                    SizedBox(
                      width: ancho,
                      height: 40,
                      child: Material(
                        color: widget.seleccionada == categoria.categoria
                            ? categoria.color.withValues(alpha: .13)
                            : colors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: .5),
                          ),
                        ),
                        child: InkWell(
                          onTap: () =>
                              widget.onSeleccionar(categoria.categoria),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(
                                  categoria.icon,
                                  color: categoria.color,
                                  size: 19,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    categoria.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: ancho,
                    height: 40,
                    child: Material(
                      color: colors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: () => setState(() => _expandido = !_expandido),
                        borderRadius: BorderRadius.circular(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _expandido
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.more_horiz_rounded,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _expandido ? 'Ver menos' : 'Ver más',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SinResultados extends StatelessWidget {
  const _SinResultados({required this.onLimpiar});

  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay publicaciones con esta etiqueta',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          TextButton(onPressed: onLimpiar, child: const Text('Ver todas')),
        ],
      ),
    );
  }
}

class _AdopcionDestacada extends StatelessWidget {
  const _AdopcionDestacada();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const orange = Color(0xFFFF9F2F);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: orange.withValues(alpha: .65)),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 120,
                  color: orange.withValues(alpha: .12),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets_rounded, color: orange, size: 58),
                      SizedBox(height: 8),
                      Text(
                        'LUNA',
                        style: TextStyle(
                          color: orange,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            'EN ADOPCIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Luna busca un hogar',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text('2 años  •  Tamaño mediano'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: colors.primary,
                              size: 19,
                            ),
                            const SizedBox(width: 4),
                            const Text('Puebla, Pue.'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {},
                            child: const Text('Conocer a Luna  ›'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: colors.primary, size: 21),
                const SizedBox(width: 6),
                const Text('24'),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                const SizedBox(width: 6),
                const Text('8'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
