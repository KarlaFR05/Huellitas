import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/avatar_helper.dart';
import '../../domain/entities/comentario.dart';
import '../../domain/entities/publicacion.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import '../bloc/comentarios_bloc.dart';
import '../widgets/publicacion_card.dart';

class ComentariosScreen extends StatelessWidget {
  const ComentariosScreen({super.key, required this.publicacion});
  final Publicacion publicacion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ComentariosBloc(repository: context.read<ForoRepository>())..add(
            ComentariosSolicitados(
              publicacionId: publicacion.id,
              recargar: true,
            ),
          ),
      child: _ComentariosView(publicacion: publicacion),
    );
  }
}

class _ComentariosView extends StatefulWidget {
  const _ComentariosView({required this.publicacion});
  final Publicacion publicacion;

  @override
  State<_ComentariosView> createState() => _ComentariosViewState();
}

class _ComentariosViewState extends State<_ComentariosView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar() {
    final contenido = _controller.text.trim();
    if (contenido.isEmpty) return;
    context.read<ComentariosBloc>().add(
      ComentarioEnviado(
        CrearComentarioSolicitud(
          publicacionId: widget.publicacion.id,
          contenido: contenido,
        ),
      ),
    );
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final usuarioId = authState is AuthSuccess && authState.data is Usuario
        ? (authState.data as Usuario).usuarioIdPk
        : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios')),
      body: BlocBuilder<ComentariosBloc, ComentariosState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => context.read<ComentariosBloc>().add(
              ComentariosSolicitados(
                publicacionId: widget.publicacion.id,
                recargar: true,
              ),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                  sliver: SliverToBoxAdapter(
                    child: PublicacionCard(
                      publicacion: widget.publicacion,
                      avatarUrl: widget.publicacion.fotoUsuarioUrl,
                      onMeGusta: () {},
                      onComentarios: () {},
                      onPerfil: widget.publicacion.usuarioId == null
                          ? null
                          : () => context.push(
                              '/mi-perfil',
                              extra: widget.publicacion.usuarioId == usuarioId
                                  ? null
                                  : widget.publicacion.usuarioId,
                            ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Comentarios',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (state.status == ComentariosStatus.cargando &&
                    state.comentarios.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == ComentariosStatus.error &&
                    state.comentarios.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => context.read<ComentariosBloc>().add(
                          ComentariosSolicitados(
                            publicacionId: widget.publicacion.id,
                            recargar: true,
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ),
                  )
                else if (state.comentarios.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text('Sé la primera persona en comentar.'),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                    sliver: SliverList.separated(
                      itemCount: state.comentarios.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comentario = state.comentarios[index];
                        return _ComentarioItem(
                          comentario: comentario,
                          onEditar: comentario.usuarioId == usuarioId
                              ? () => _editarComentario(comentario)
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<ComentariosBloc, ComentariosState>(
                buildWhen: (anterior, actual) =>
                    anterior.enviando != actual.enviando,
                builder: (context, state) => IconButton.filled(
                  onPressed: state.enviando ? null : _enviar,
                  icon: state.enviando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editarComentario(Comentario comentario) async {
    final controller = TextEditingController(text: comentario.contenido);
    final contenido = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Comentario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final texto = controller.text.trim();
              if (texto.isNotEmpty) Navigator.pop(dialogContext, texto);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (contenido == null || !mounted) return;
    context.read<ComentariosBloc>().add(
      ComentarioEditado(comentarioId: comentario.id, contenido: contenido),
    );
  }
}

class _ComentarioItem extends StatelessWidget {
  const _ComentarioItem({required this.comentario, this.onEditar});
  final Comentario comentario;
  final VoidCallback? onEditar;

  String _fecha() {
    final diferencia = DateTime.now().difference(comentario.fechaCreacion);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
    return 'Hace ${diferencia.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: comentario.fotoUsuarioUrl == null
              ? null
              : avatarProvider(comentario.fotoUsuarioUrl),
          child: comentario.fotoUsuarioUrl == null
              ? const Icon(Icons.person_outline_rounded)
              : null,
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (onEditar != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Editar comentario',
                      visualDensity: VisualDensity.compact,
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit_outlined, size: 19),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(comentario.contenido),
                const SizedBox(height: 6),
                Text(_fecha(), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
