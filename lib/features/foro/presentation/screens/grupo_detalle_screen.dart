import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        _grupo = grupo;
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
    if (_grupo.solicitudPendiente) return;
    try {
      final repository = context.read<ForoRepository>();
      late Grupo actualizado;
      if (!_grupo.esMiembro && _grupo.privacidad == PrivacidadGrupo.privado) {
        actualizado = await repository.solicitarIngresoGrupo(_grupo.id);
        actualizado = actualizado.copyWith(solicitudPendiente: true);
      } else if (_grupo.esMiembro) {
        actualizado = await repository.salirDeGrupo(_grupo.id);
      } else {
        actualizado = await repository.unirseAGrupo(_grupo.id);
      }
      if (mounted) setState(() => _grupo = actualizado);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(error))));
      }
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

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final usuarioId = authState is AuthSuccess && authState.data is Usuario
        ? (authState.data as Usuario).usuarioIdPk
        : null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _grupo);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comunidad'),
          actions: [
            if (_grupo.esAdministradorActual)
              IconButton(
                tooltip: 'Editar grupo',
                onPressed: _editarGrupo,
                icon: const Icon(Icons.edit_outlined),
              ),
            if (_grupo.esAdministradorActual)
              IconButton(
                tooltip: 'Administrar miembros',
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdministrarGrupoScreen(grupo: _grupo),
                  ),
                ),
                icon: const Icon(Icons.manage_accounts_outlined),
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
