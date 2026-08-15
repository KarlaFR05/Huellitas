import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensaje_error.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/grupo.dart';
import '../../domain/entities/publicacion.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import '../widgets/publicacion_card.dart';
import '../widgets/grupo_imagen.dart';
import 'comentarios_screen.dart';
import 'crear_grupo_screen.dart';
import 'crear_publicacion_screen.dart';
import 'administrar_grupo_screen.dart';

enum _AccionGrupo { solicitudes, miembros, editar, eliminar }

class _OpcionGrupo extends StatelessWidget {
  const _OpcionGrupo({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.accion,
    this.esDestructiva = false,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final _AccionGrupo accion;
  final bool esDestructiva;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = esDestructiva ? colors.error : colors.primary;
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
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
          subtitle: Text(subtitulo),
          trailing: Icon(Icons.chevron_right_rounded, color: color),
          onTap: () => Navigator.pop(context, accion),
        ),
      ),
    );
  }
}

class GrupoDetalleScreen extends StatefulWidget {
  final Grupo grupo;

  const GrupoDetalleScreen({super.key, required this.grupo});

  @override
  State<GrupoDetalleScreen> createState() => _GrupoDetalleScreenState();
}

class _GrupoDetalleScreenState extends State<GrupoDetalleScreen> {
  late Grupo _grupo;
  final List<Publicacion> _publicaciones = [];
  bool _inicializado = false;
  bool _cargando = true;
  bool _actualizandoMembresia = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _grupo = widget.grupo;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final repository = context.read<ForoRepository>();
      final grupo = await repository.obtenerGrupo(_grupo.id);
      final pagina = await repository.obtenerFeed(
        FiltroPublicaciones(grupoId: _grupo.id),
      );
      if (!mounted) return;
      setState(() {
        _grupo = grupo.copyWith(
          esMiembro: grupo.esMiembro || _grupo.esMiembro,
          esAdministradorActual:
              grupo.esAdministradorActual || _grupo.esAdministradorActual,
        );
        _publicaciones
          ..clear()
          ..addAll(pagina.elementos);
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = mensajeDeError(error);
      });
    }
  }

  Future<void> _cambiarMembresia() async {
    if (_grupo.solicitudPendiente ||
        _grupo.esMiembro ||
        _actualizandoMembresia) {
      return;
    }
    setState(() => _actualizandoMembresia = true);
    try {
      final repository = context.read<ForoRepository>();
      late Grupo actualizado;
      if (!_grupo.esMiembro && _grupo.privacidad == PrivacidadGrupo.privado) {
        actualizado = await repository.solicitarIngresoGrupo(_grupo.id);
        actualizado = actualizado.copyWith(solicitudPendiente: true);
      } else {
        actualizado = await repository.unirseAGrupo(_grupo.id);
        actualizado = actualizado.copyWith(esMiembro: true);
      }
      if (mounted) setState(() => _grupo = actualizado);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
    } finally {
      if (mounted) setState(() => _actualizandoMembresia = false);
    }
  }

  Future<void> _salirDelGrupo() async {
    if (_actualizandoMembresia) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Salir del grupo'),
        content: Text('¿Seguro que quieres salir de ${_grupo.nombre}?'),
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
    if (confirmar != true || !mounted) return;
    setState(() => _actualizandoMembresia = true);
    try {
      final respuesta = await context.read<ForoRepository>().salirDeGrupo(
        _grupo.id,
      );
      if (!mounted) return;
      _grupo = respuesta.copyWith(esMiembro: false);
      Navigator.pop(context, _grupo);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
    } finally {
      if (mounted) setState(() => _actualizandoMembresia = false);
    }
  }

  Future<void> _eliminarGrupo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          '¿Seguro que quieres eliminar ${_grupo.nombre}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    try {
      await context.read<ForoRepository>().eliminarGrupo(_grupo.id);
      if (!mounted) return;
      _grupo = _grupo.copyWith(estado: EstadoGrupo.eliminado);
      Navigator.pop(context, _grupo);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
    }
  }

  Future<void> _abrirAdministracion(int tab) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AdministrarGrupoScreen(grupo: _grupo, initialTab: tab),
      ),
    );
  }

  Future<void> _mostrarMenuAdministrador() async {
    final accion = await showModalBottomSheet<_AccionGrupo>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administrar comunidad',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              if (_grupo.privacidad == PrivacidadGrupo.privado)
                _OpcionGrupo(
                  icono: Icons.person_add_alt_1_rounded,
                  titulo: 'Solicitudes',
                  subtitulo: 'Revisa quién quiere entrar',
                  accion: _AccionGrupo.solicitudes,
                ),
              const _OpcionGrupo(
                icono: Icons.groups_2_outlined,
                titulo: 'Miembros',
                subtitulo: 'Administra las personas del grupo',
                accion: _AccionGrupo.miembros,
              ),
              const _OpcionGrupo(
                icono: Icons.edit_outlined,
                titulo: 'Editar grupo',
                subtitulo: 'Cambia información e imágenes',
                accion: _AccionGrupo.editar,
              ),
              _OpcionGrupo(
                icono: Icons.delete_outline_rounded,
                titulo: 'Eliminar grupo',
                subtitulo: 'Elimina esta comunidad definitivamente',
                accion: _AccionGrupo.eliminar,
                esDestructiva: true,
              ),
            ],
          ),
        ),
      ),
    );
    if (accion == null || !mounted) return;
    switch (accion) {
      case _AccionGrupo.solicitudes:
        await _abrirAdministracion(0);
      case _AccionGrupo.miembros:
        await _abrirAdministracion(
          _grupo.privacidad == PrivacidadGrupo.privado ? 1 : 0,
        );
      case _AccionGrupo.editar:
        await _editarGrupo();
      case _AccionGrupo.eliminar:
        await _eliminarGrupo();
    }
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

    try {
      final creada = await context.read<ForoRepository>().crearPublicacion(
        CrearPublicacionSolicitud(
          titulo: resultado['titulo'] as String,
          contenido: resultado['contenido'] as String,
          categoria: resultado['categoria'] as CategoriaPublicacion,
          grupoId: _grupo.id,
          imagenLocalPath: (resultado['imagen'] as dynamic)?.path as String?,
        ),
      );
      if (mounted) setState(() => _publicaciones.insert(0, creada));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
    }
  }

  Future<void> _editarGrupo() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => CrearGrupoScreen(grupo: _grupo)),
    );
    if (resultado == null || !mounted) return;
    try {
      final actualizado = await context.read<ForoRepository>().actualizarGrupo(
        _grupo.id,
        nombre: resultado['nombre'] as String,
        descripcion: resultado['descripcion'] as String,
        privacidad: resultado['privacidad'] as PrivacidadGrupo,
        fotoPerfilLocalPath: resultado['perfilPath'] as String?,
        fotoPortadaLocalPath: resultado['portadaPath'] as String?,
      );
      if (mounted) setState(() => _grupo = actualizado);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
    }
  }

  Future<void> _editarPublicacionGrupo(Publicacion publicacion) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearPublicacionScreen(publicacion: publicacion),
      ),
    );
    if (resultado == null || !mounted) return;
    try {
      final actualizada = await context
          .read<ForoRepository>()
          .actualizarPublicacion(
            publicacion.id,
            titulo: resultado['titulo'] as String,
            contenido: resultado['contenido'] as String,
            categoria: resultado['categoria'] as CategoriaPublicacion,
            imagenLocalPath: (resultado['imagen'] as dynamic)?.path as String?,
          );
      final index = _publicaciones.indexWhere(
        (item) => item.id == actualizada.id,
      );
      if (mounted && index >= 0) {
        setState(() => _publicaciones[index] = actualizada);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
    }
  }

  Future<void> _confirmarEliminarPublicacionGrupo(
    Publicacion publicacion,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta publicación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    try {
      await context.read<ForoRepository>().eliminarPublicacion(publicacion.id);
      if (!mounted) return;
      setState(() {
        _publicaciones.removeWhere((item) => item.id == publicacion.id);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final usuarioId = authState is AuthSuccess && authState.data is Usuario
        ? (authState.data as Usuario).usuarioIdPk
        : null;
    final esAdministrador =
        _grupo.esAdministradorActual || _grupo.creadorUsuarioId == usuarioId;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _grupo);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comunidad'),
          actions: [
            if (_grupo.esMiembro && !esAdministrador)
              IconButton(
                tooltip: 'Salir del grupo',
                onPressed: _actualizandoMembresia ? null : _salirDelGrupo,
                icon: const Icon(Icons.logout_rounded),
              ),
            if (esAdministrador)
              IconButton(
                tooltip: 'Opciones del grupo',
                onPressed: _mostrarMenuAdministrador,
                icon: const Icon(Icons.more_vert_rounded),
              ),
          ],
        ),
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
                      child: _grupo.solicitudPendiente
                          ? OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.schedule_rounded),
                              label: const Text('Solicitud pendiente'),
                            )
                          : _grupo.esMiembro
                          ? OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Ya eres miembro'),
                            )
                          : FilledButton.icon(
                              onPressed: _actualizandoMembresia
                                  ? null
                                  : _cambiarMembresia,
                              icon: _actualizandoMembresia
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_rounded),
                              label: Text(
                                _actualizandoMembresia
                                    ? 'Uniéndote...'
                                    : 'Unirme al grupo',
                              ),
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
              itemCount: _cargando || _error != null || _publicaciones.isEmpty
                  ? 1
                  : _publicaciones.length,
              itemBuilder: (context, index) {
                if (_cargando) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (_error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _cargar,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ),
                  );
                }
                if (_publicaciones.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Este grupo todavía no tiene publicaciones.'),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: PublicacionCard(
                    publicacion: _publicaciones[index],
                    avatarUrl: _publicaciones[index].fotoUsuarioUrl,
                    onPerfil: _publicaciones[index].usuarioId == null
                        ? null
                        : () => context.push(
                            '/mi-perfil',
                            extra: _publicaciones[index].usuarioId == usuarioId
                                ? null
                                : _publicaciones[index].usuarioId,
                          ),
                    onMeGusta: () async {
                      try {
                        final actualizada = await context
                            .read<ForoRepository>()
                            .cambiarMeGusta(_publicaciones[index].id);
                        if (mounted) {
                          setState(() => _publicaciones[index] = actualizada);
                        }
                      } catch (_) {}
                    },
                    onComentarios: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComentariosScreen(
                          publicacion: _publicaciones[index],
                        ),
                      ),
                    ),
                    onEditar: _publicaciones[index].usuarioId == usuarioId
                        ? () => _editarPublicacionGrupo(_publicaciones[index])
                        : null,
                    onEliminar: _publicaciones[index].usuarioId == usuarioId
                        ? () => _confirmarEliminarPublicacionGrupo(
                            _publicaciones[index],
                          )
                        : null,
                  ),
                );
              },
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
