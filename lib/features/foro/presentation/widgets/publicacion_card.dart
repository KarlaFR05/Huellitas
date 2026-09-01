import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/avatar_helper.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../../insignias/data/repositories/insignia_repository_impl.dart';
import '../../../insignias/domain/entities/insignia.dart';
import '../../domain/entities/publicacion.dart';

class PublicacionCard extends StatelessWidget {
  const PublicacionCard({
    super.key,
    required this.publicacion,
    required this.onMeGusta,
    required this.onComentarios,
    this.avatarAsset,
    this.avatarUrl,
    this.onEditar,
    this.onEliminar,
    this.onPerfil,
    this.autorVerificado = false,
  });

  final Publicacion publicacion;
  final VoidCallback onMeGusta;
  final VoidCallback onComentarios;
  final String? avatarAsset;
  final String? avatarUrl;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onPerfil;
  final bool autorVerificado;

  String _formatearFecha(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
    return 'Hace ${diferencia.inDays} días';
  }

  ({String nombre, IconData icon, Color color}) _datosCategoria() {
    return switch (publicacion.categoria) {
      CategoriaPublicacion.adopcion => (
        nombre: 'Adopción',
        icon: Icons.pets_rounded,
        color: const Color(0xFFFF9F2F),
      ),
      CategoriaPublicacion.vacunacion => (
        nombre: 'Vacunación',
        icon: Icons.vaccines_rounded,
        color: const Color(0xFF3679D8),
      ),
      CategoriaPublicacion.salud => (
        nombre: 'Salud',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFF27A56D),
      ),
      CategoriaPublicacion.extraviados => (
        nombre: 'Extraviado',
        icon: Icons.search_rounded,
        color: const Color(0xFF7557D5),
      ),
      CategoriaPublicacion.alimentacion => (
        nombre: 'Alimentación',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFF69B643),
      ),
      CategoriaPublicacion.entrenamiento => (
        nombre: 'Entrenamiento',
        icon: Icons.school_rounded,
        color: const Color(0xFF3971C8),
      ),
      CategoriaPublicacion.cuidado => (
        nombre: 'Cuidado',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE65B70),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final categoria = _datosCategoria();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: onPerfil,
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: avatarUrl != null
                        ? avatarProvider(avatarUrl)
                        : avatarAsset == null
                        ? null
                        : AssetImage(avatarAsset!),
                    child: avatarAsset == null && avatarUrl == null
                        ? Icon(Icons.person_rounded, color: colors.primary)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: onPerfil,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  publicacion.nombreUsuario,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (publicacion.usuarioId != null) ...[
                                const SizedBox(width: 6),
                                _InsigniaAutor(
                                  usuarioId: publicacion.usuarioId!,
                                ),
                              ],

                              if (autorVerificado) ...[
                                const SizedBox(width: 6),
                                const OrganizacionVerificadaBadge(size: 18),
                              ],
                            ],
                          ),
                          Text(
                            _formatearFecha(publicacion.fecha),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _EtiquetaPublicacion(
                      texto: categoria.nombre,
                      icono: categoria.icon,
                      color: categoria.color,
                    ),
                    if (publicacion.nombreGrupo != null) ...[
                      const SizedBox(height: 5),
                      _EtiquetaPublicacion(
                        texto: publicacion.nombreGrupo!,
                        icono: Icons.groups_rounded,
                        color: colors.primary,
                      ),
                    ],
                  ],
                ),
                if (onEditar != null || onEliminar != null)
                  IconButton(
                    tooltip: 'Opciones de publicación',
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () => _mostrarOpciones(context),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publicacion.titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(publicacion.contenido),
              ],
            ),
          ),
          if (publicacion.imagenUrl != null)
            GestureDetector(
              onTap: () => _mostrarImagenCompleta(
                context,
                Image.network(publicacion.imagenUrl!, fit: BoxFit.contain),
              ),
              child: Image.network(
                publicacion.imagenUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 150,
                  color: colors.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          if (publicacion.imagenPath != null)
            GestureDetector(
              onTap: () => _mostrarImagenCompleta(
                context,
                Image.file(File(publicacion.imagenPath!), fit: BoxFit.contain),
              ),
              child: Image.file(
                File(publicacion.imagenPath!),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onMeGusta,
                  icon: Icon(
                    publicacion.leGustaAlUsuario
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: publicacion.leGustaAlUsuario
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  label: Text('${publicacion.meGusta}'),
                ),
                TextButton.icon(
                  onPressed: onComentarios,
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: Text('${publicacion.comentarios}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarOpciones(BuildContext context) async {
    final accion = await showModalBottomSheet<_AccionPublicacion>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opciones de la publicación',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                if (onEditar != null)
                  _OpcionPublicacion(
                    icono: Icons.edit_outlined,
                    titulo: 'Editar publicación',
                    subtitulo: 'Modifica el contenido o la imagen',
                    color: colors.primary,
                    onTap: () =>
                        Navigator.pop(sheetContext, _AccionPublicacion.editar),
                  ),
                if (onEliminar != null)
                  _OpcionPublicacion(
                    icono: Icons.delete_outline_rounded,
                    titulo: 'Eliminar publicación',
                    subtitulo: 'Esta acción no se puede deshacer',
                    color: colors.error,
                    onTap: () => Navigator.pop(
                      sheetContext,
                      _AccionPublicacion.eliminar,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (accion == _AccionPublicacion.editar) onEditar?.call();
    if (accion == _AccionPublicacion.eliminar) onEliminar?.call();
  }

  void _mostrarImagenCompleta(BuildContext context, Widget imagen) {
    showFullScreenImage(
      context,
      image: imagen,
      semanticLabel: 'Imagen de la publicación ${publicacion.titulo}',
    );
  }
}

enum _AccionPublicacion { editar, eliminar }

class _OpcionPublicacion extends StatelessWidget {
  const _OpcionPublicacion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: color),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitulo),
          trailing: Icon(Icons.chevron_right_rounded, color: color),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _InsigniaAutor extends StatefulWidget {
  const _InsigniaAutor({required this.usuarioId});

  final int usuarioId;

  @override
  State<_InsigniaAutor> createState() => _InsigniaAutorState();
}

class _InsigniaAutorState extends State<_InsigniaAutor> {
  late final Future<Insignia?> _insignia;

  @override
  void initState() {
    super.initState();
    _insignia = _cargar();
  }

  Future<Insignia?> _cargar() async {
    try {
      final porCategoria = await context
          .read<InsigniaRepositoryImpl>()
          .obtenerTodasLasInsignias(widget.usuarioId);
      final obtenidas =
          porCategoria.values
              .expand((lista) => lista)
              .where((item) => item.obtenida)
              .toList()
            ..sort((a, b) => b.nivel.compareTo(a.nivel));
      return obtenidas.isEmpty ? null : obtenidas.first;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Insignia?>(
      future: _insignia,
      builder: (context, snapshot) {
        final insignia = snapshot.data;
        if (insignia == null) return const SizedBox.shrink();
        final color = Theme.of(context).colorScheme.primary;
        return Tooltip(
          message: '${insignia.nombre} · Nivel ${insignia.nivel}',
          child: SizedBox(
            width: 23,
            height: 23,
            child: insignia.imagenUrl?.isNotEmpty == true
                ? Image.network(
                    insignia.imagenUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.workspace_premium_rounded,
                      color: color,
                      size: 20,
                    ),
                  )
                : Icon(Icons.workspace_premium_rounded, color: color, size: 20),
          ),
        );
      },
    );
  }
}

class _EtiquetaPublicacion extends StatelessWidget {
  const _EtiquetaPublicacion({
    required this.texto,
    required this.icono,
    required this.color,
  });

  final String texto;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
