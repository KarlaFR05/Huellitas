import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/widgets/avatar_helper.dart';
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
  });

  final Publicacion publicacion;
  final VoidCallback onMeGusta;
  final VoidCallback onComentarios;
  final String? avatarAsset;
  final String? avatarUrl;
  final VoidCallback? onEditar;

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
                CircleAvatar(
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        publicacion.nombreUsuario,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _formatearFecha(publicacion.fecha),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEditar != null)
                  IconButton(
                    tooltip: 'Editar publicación',
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined),
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
            Image.network(
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
          if (publicacion.imagenPath != null)
            Image.file(
              File(publicacion.imagenPath!),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
