import 'package:flutter/material.dart';

import '../../domain/entities/comentario.dart';
import '../../domain/entities/publicacion.dart';
import '../widgets/publicacion_card.dart';

class ComentariosScreen extends StatefulWidget {
  final Publicacion publicacion;

  const ComentariosScreen({super.key, required this.publicacion});

  @override
  State<ComentariosScreen> createState() => _ComentariosScreenState();
}

class _ComentariosScreenState extends State<ComentariosScreen> {
  final TextEditingController _comentarioController = TextEditingController();

  final List<Comentario> _comentarios = [
    Comentario(
      id: 1,
      publicacionId: 1,
      nombreUsuario: 'Ana Martínez',
      contenido: 'Espero que pronto encuentren a su familia.',
      fechaCreacion: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    Comentario(
      id: 2,
      publicacionId: 1,
      nombreUsuario: 'Carlos Hernández',
      contenido: 'Compartiré la información.',
      fechaCreacion: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    }

    if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    }

    if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    }

    return 'Hace ${diferencia.inDays} días';
  }

  void _enviarComentario() {
    final contenido = _comentarioController.text.trim();

    if (contenido.isEmpty) {
      return;
    }

    setState(() {
      _comentarios.add(
        Comentario(
          id: DateTime.now().millisecondsSinceEpoch,
          publicacionId: widget.publicacion.id,
          nombreUsuario: 'Usuario actual',
          contenido: contenido,
          fechaCreacion: DateTime.now(),
        ),
      );
    });

    _comentarioController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios'), centerTitle: true),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 310),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: PublicacionCard(
                publicacion: widget.publicacion,
                avatarAsset: 'assets/images/avatares/avatar_01.png',
                onMeGusta: () {},
                onComentarios: () {},
              ),
            ),
          ),
          Expanded(
            child: _comentarios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 70,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Todavía no hay comentarios',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sé la primera persona en comentar.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comentarios.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comentario = _comentarios[index];

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comentario.nombreUsuario,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comentario.contenido),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatearFecha(comentario.fechaCreacion),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(Icons.person, color: colors.onPrimaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _comentarioController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _enviarComentario(),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: _enviarComentario,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
