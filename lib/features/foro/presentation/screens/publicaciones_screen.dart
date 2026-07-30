import 'package:flutter/material.dart';

import '../../domain/entities/publicacion.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../widgets/publicacion_card.dart';
import 'comentarios_screen.dart';
import 'crear_publicacion_screen.dart';

class PublicacionesScreen extends StatefulWidget {
  const PublicacionesScreen({super.key});

  @override
  State<PublicacionesScreen> createState() => _PublicacionesScreenState();
}

class _PublicacionesScreenState extends State<PublicacionesScreen> {
  final List<Publicacion> _publicaciones = [
    Publicacion(
      id: 1,
      titulo: 'Perrito perdido',
      nombreUsuario: 'María López',
      contenido:
          'Encontré un perrito cerca del centro. Parece estar perdido y tiene un collar azul.',
      fecha: DateTime.now().subtract(const Duration(minutes: 35)),
      meGusta: 14,
      comentarios: 5,
      categoria: CategoriaPublicacion.extraviados,
    ),
    Publicacion(
      id: 2,
      titulo: 'Campaña de esterilización',
      nombreUsuario: 'Carlos Hernández',
      contenido:
          'Comparto información sobre una campaña de esterilización a bajo costo este fin de semana.',
      fecha: DateTime.now().subtract(const Duration(hours: 3)),
      meGusta: 28,
      comentarios: 7,
      categoria: CategoriaPublicacion.salud,
    ),
    Publicacion(
      id: 3,
      titulo: 'Rescate completado',
      nombreUsuario: 'Ana Martínez',
      contenido:
          'Gracias a las personas que ayudaron con el rescate de la gatita. Ya se encuentra a salvo.',
      fecha: DateTime.now().subtract(const Duration(days: 1)),
      meGusta: 42,
      comentarios: 12,
      categoria: CategoriaPublicacion.cuidado,
    ),
    Publicacion(
      id: 4,
      titulo: 'Necesitamos apoyo para un rescate',
      nombreUsuario: 'Sofía Ramírez',
      contenido:
          'Buscamos voluntarios que puedan ayudarnos con el traslado de un perrito rescatado esta tarde.',
      fecha: DateTime.now().subtract(const Duration(hours: 2)),
      meGusta: 31,
      comentarios: 9,
      categoria: CategoriaPublicacion.adopcion,
      nombreGrupo: 'Rescatistas Huellitas',
    ),
  ];

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
  CategoriaPublicacion? _filtroActivo;

  void _alternarMeGusta(int index) {
    final publicacion = _publicaciones[index];
    final nuevoEstado = !publicacion.leGustaAlUsuario;
    setState(() {
      _publicaciones[index] = publicacion.copyWith(
        leGustaAlUsuario: nuevoEstado,
        meGusta: publicacion.meGusta + (nuevoEstado ? 1 : -1),
      );
    });
  }

  Future<void> _abrirComentarios(Publicacion publicacion) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ComentariosScreen(publicacion: publicacion),
      ),
    );
  }

  Future<void> _crearPublicacion() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()),
    );
    if (resultado == null || !mounted) return;

    setState(() {
      _publicaciones.insert(
        0,
        Publicacion(
          id: DateTime.now().millisecondsSinceEpoch,
          titulo: resultado['titulo'] as String,
          nombreUsuario: 'Usuario actual',
          contenido: resultado['contenido'] as String,
          categoria: resultado['categoria'] as CategoriaPublicacion,
          imagenPath: (resultado['imagen'] as dynamic)?.path as String?,
          fecha: DateTime.now(),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicación creada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicacionesVisibles = _filtroActivo == null
        ? _publicaciones
        : _publicaciones
              .where((publicacion) => publicacion.categoria == _filtroActivo)
              .toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () =>
            Future<void>.delayed(const Duration(milliseconds: 700)),
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
              seleccionada: _filtroActivo,
              onSeleccionar: (categoria) {
                setState(() {
                  _filtroActivo = _filtroActivo == categoria ? null : categoria;
                });
              },
            ),
            const SizedBox(height: 18),
            if (_filtroActivo == null ||
                _filtroActivo == CategoriaPublicacion.adopcion) ...[
              const _AdopcionDestacada(),
              const SizedBox(height: 10),
            ],
            if (publicacionesVisibles.isEmpty &&
                _filtroActivo != CategoriaPublicacion.adopcion)
              _SinResultados(
                onLimpiar: () => setState(() => _filtroActivo = null),
              ),
            for (final publicacion in publicacionesVisibles)
              PublicacionCard(
                publicacion: publicacion,
                avatarAsset:
                    'assets/images/avatares/avatar_0${(_publicaciones.indexOf(publicacion) % 6) + 1}.png',
                onMeGusta: () =>
                    _alternarMeGusta(_publicaciones.indexOf(publicacion)),
                onComentarios: () => _abrirComentarios(publicacion),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: BottomBarWidget.contentClearance(context) + 18,
        ),
        child: FloatingActionButton.extended(
          onPressed: _crearPublicacion,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Publicar'),
        ),
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
