import 'package:flutter/material.dart';

import '../../domain/entities/grupo.dart';
import '../../domain/entities/publicacion.dart';
import '../widgets/publicacion_card.dart';
import '../widgets/grupo_imagen.dart';
import 'comentarios_screen.dart';
import 'crear_publicacion_screen.dart';

class GrupoDetalleScreen extends StatefulWidget {
  final Grupo grupo;

  const GrupoDetalleScreen({super.key, required this.grupo});

  @override
  State<GrupoDetalleScreen> createState() => _GrupoDetalleScreenState();
}

class _GrupoDetalleScreenState extends State<GrupoDetalleScreen> {
  late Grupo _grupo;
  final List<Publicacion> _publicaciones = [];

  @override
  void initState() {
    super.initState();
    _grupo = widget.grupo;
    _publicaciones.add(
      Publicacion(
        id: 101,
        titulo: 'Bienvenidos al grupo',
        nombreUsuario: 'Administración',
        contenido:
            'Este espacio es para compartir información relacionada con ${_grupo.nombre}.',
        fecha: DateTime.now().subtract(const Duration(hours: 5)),
        meGusta: 9,
        comentarios: 2,
        categoria: CategoriaPublicacion.cuidado,
        nombreGrupo: _grupo.nombre,
      ),
    );
  }

  void _cambiarMembresia() {
    final seUne = !_grupo.esMiembro;
    setState(() {
      _grupo = _grupo.copyWith(
        esMiembro: seUne,
        cantidadMiembros: _grupo.cantidadMiembros + (seUne ? 1 : -1),
      );
    });
  }

  Future<void> _crearPublicacion() async {
    if (!_grupo.esMiembro) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Únete al grupo para poder publicar')),
      );
      return;
    }

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
          nombreGrupo: _grupo.nombre,
          imagenPath: (resultado['imagen'] as dynamic)?.path as String?,
          fecha: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _grupo);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Comunidad')),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 235,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    portadaGrupo(_grupo),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .68),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 43,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            child: CircleAvatar(
                              radius: 38,
                              backgroundImage: imagenPerfilGrupo(_grupo),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _grupo.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    height: 1.05,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.groups_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${_grupo.cantidadMiembros} miembros',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 21,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Acerca del grupo',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _grupo.descripcion,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: _grupo.esMiembro
                          ? OutlinedButton.icon(
                              onPressed: _cambiarMembresia,
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Ya eres miembro'),
                            )
                          : FilledButton.icon(
                              onPressed: _cambiarMembresia,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Unirme al grupo'),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Publicaciones recientes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _publicaciones.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PublicacionCard(
                  publicacion: _publicaciones[index],
                  avatarAsset: _grupo.fotoPerfil,
                  onMeGusta: () {
                    final publicacion = _publicaciones[index];
                    final leGusta = !publicacion.leGustaAlUsuario;
                    setState(() {
                      _publicaciones[index] = publicacion.copyWith(
                        leGustaAlUsuario: leGusta,
                        meGusta: publicacion.meGusta + (leGusta ? 1 : -1),
                      );
                    });
                  },
                  onComentarios: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ComentariosScreen(publicacion: _publicaciones[index]),
                    ),
                  ),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _crearPublicacion,
          icon: const Icon(Icons.add),
          label: const Text('Publicar'),
        ),
      ),
    );
  }
}
