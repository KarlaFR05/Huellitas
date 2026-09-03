import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/storage/organizaciones_seguidas_storage.dart';
import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../foro/presentation/bloc/foro_bloc.dart';
import '../../../foro/presentation/bloc/foro_event.dart';
import '../../domain/entities/organizacion_foro.dart';
import '../../domain/entities/publicacion.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import '../../data/datasources/organizacion_foro_datasource.dart';
import '../../data/repositories/organizacion_foro_repository_impl.dart';
import '../widgets/publicacion_card.dart';
import 'comentarios_screen.dart';

class OrganizacionPerfilScreen extends StatefulWidget {
  final OrganizacionForo organizacion;
  final List<Publicacion> publicaciones;
  final ValueChanged<OrganizacionForo>? onSeguimientoChanged;

  const OrganizacionPerfilScreen({
    super.key,
    required this.organizacion,
    this.publicaciones = const [],
    this.onSeguimientoChanged,
  });

  @override
  State<OrganizacionPerfilScreen> createState() =>
      _OrganizacionPerfilScreenState();
}

class _OrganizacionPerfilScreenState extends State<OrganizacionPerfilScreen> {
  late String _descripcion;
  late String _logoUrl;
  late String _portadaUrl;
  late bool _siguiendo;
  late int _seguidores;
  late final OrganizacionForoRepositoryImpl _organizacionRepository;
  final _seguimientoStorage = OrganizacionesSeguidasStorage();

  bool _esDueno = false;
  bool _actualizandoSeguimiento = false;
  bool _yaSeMostroBienvenida = false;
  bool _subiendoImagen = false;
  bool _guardandoDescripcion = false;
  bool _cargandoPublicaciones = true;

  final Map<int, OrganizacionForo> _mapaOrgs = {};
  bool _orgsCargadas = false;
  List<Publicacion> _publicaciones = [];

  final _picker = ImagePicker();
  File? _perfilFile;
  File? _portadaFile;
  int _usuarioId = 0;

  @override
  void initState() {
    super.initState();
    _descripcion = widget.organizacion.descripcion;
    _logoUrl = widget.organizacion.logoUrl;
    _portadaUrl = widget.organizacion.fotoPortada;
    _siguiendo = widget.organizacion.esSeguidor;
    _seguidores = widget.organizacion.cantidadSeguidores;
    _organizacionRepository = OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(context.read<Dio>()),
    );

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      final usuario = authState.data as Usuario;
      _usuarioId = usuario.usuarioIdPk;
      _esDueno = widget.organizacion.usuarioId == usuario.usuarioIdPk;
    }

    if (widget.publicaciones.isEmpty) {
      _cargarPublicaciones();
    } else {
      _publicaciones = widget.publicaciones;
      _cargandoPublicaciones = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarBienvenidaSiEsNecesario();
    });
  }

  Future<void> _cargarPublicaciones() async {
    try {
      final repository = context.read<ForoRepository>();
      
      // La API filtra por organización, no por el usuario propietario.
      final pagina = await repository.obtenerFeed(
        FiltroPublicaciones(organizacionId: widget.organizacion.id),
      );
      
      if (!mounted) return;
      
      setState(() {
        _publicaciones = pagina.elementos;
        _cargandoPublicaciones = false;
      });

      if (_publicaciones.isNotEmpty) {
        _cargarOrganizacionesDePublicaciones(_publicaciones);
      }
    } catch (e) {
      print('Error al cargar publicaciones: $e');
      if (!mounted) return;
      setState(() {
        _cargandoPublicaciones = false;
      });
    }
  }

  void _cargarOrganizacionesDePublicaciones(List<Publicacion> publicaciones) {
    if (_orgsCargadas) return;

    final usuarioIds = publicaciones
        .where((p) => p.usuarioId != null)
        .map((p) => p.usuarioId!)
        .toSet()
        .toList();

    if (usuarioIds.isEmpty) {
      _orgsCargadas = true;
      return;
    }

    final dio = context.read<Dio>();
    OrganizacionForoRepositoryImpl(
      OrganizacionForoRemoteDataSourceImpl(dio),
    )
        .obtenerOrganizacionesVerificadas()
        .then((orgs) {
      if (!mounted) return;
      final mapa = <int, OrganizacionForo>{};
      for (final org in orgs) {
        mapa[org.usuarioId] = org;
      }
      setState(() {
        _mapaOrgs.addAll(mapa);
        _orgsCargadas = true;
      });
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _orgsCargadas = true;
        });
      }
    });
  }

  void _mostrarBienvenidaSiEsNecesario() {
    if (!_esDueno || _yaSeMostroBienvenida) return;

    final faltaLogo = _logoUrl.isEmpty;
    final faltaPortada = _portadaUrl.isEmpty;
    final faltaDescripcion = _descripcion.trim().isEmpty;

    if (faltaLogo || faltaPortada || faltaDescripcion) {
      _yaSeMostroBienvenida = true;
      _mostrarDialogoBienvenida(faltaLogo, faltaPortada, faltaDescripcion);
    }
  }

  void _mostrarDialogoBienvenida(
    bool faltaLogo,
    bool faltaPortada,
    bool faltaDescripcion,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('¡Bienvenido!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para que tu organización luzca completa, te recomendamos:',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (faltaLogo)
              _PasoBienvenida(
                numero: 1,
                texto: 'Agregar una foto de perfil',
                icono: Icons.account_circle_outlined,
              ),
            if (faltaPortada)
              _PasoBienvenida(
                numero: faltaLogo ? 2 : 1,
                texto: 'Agregar una foto de portada',
                icono: Icons.image_outlined,
              ),
            if (faltaDescripcion)
              _PasoBienvenida(
                numero: (faltaLogo ? 2 : 1) + (faltaPortada ? 1 : 0),
                texto: 'Agregar una descripción',
                icono: Icons.description_outlined,
              ),
            const SizedBox(height: 16),
            Text(
              'Puedes hacer esto tocando los iconos de camara en las imagenes o haciendo clic en el nombre de la organizacion para editar la descripcion.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSeguir() async {
    if (_actualizandoSeguimiento) return;

    final siguiendoAntes = _siguiendo;
    setState(() => _actualizandoSeguimiento = true);

    try {
      final resultado = await _organizacionRepository.toggleSeguir(
        widget.organizacion.id,
      );

      var siguiendoConfirmado = resultado.siguiendo;
      var seguidoresConfirmados = resultado.cantidadSeguidores;
      if (siguiendoConfirmado == null) {
        try {
          final organizaciones = await _organizacionRepository
              .obtenerOrganizacionesVerificadas();
          final actualizada = organizaciones
              .where((item) => item.id == widget.organizacion.id)
              .firstOrNull;
          if (actualizada != null) {
            seguidoresConfirmados ??= actualizada.cantidadSeguidores;
            if (actualizada.cantidadSeguidores != _seguidores) {
              siguiendoConfirmado =
                  actualizada.cantidadSeguidores > _seguidores;
            }
          }
        } catch (_) {
          // La confirmacion es auxiliar; el POST ya fue exitoso.
        }
      }

      if (!mounted) return;

      setState(() {
        _siguiendo = siguiendoConfirmado ?? !siguiendoAntes;
        _seguidores =
            seguidoresConfirmados ??
            (_seguidores + (_siguiendo ? 1 : -1))
                .clamp(0, 1 << 31)
                .toInt();
      });

      try {
        await _seguimientoStorage.actualizar(
          usuarioId: _usuarioId,
          organizacionId: widget.organizacion.id,
          siguiendo: _siguiendo,
        );
      } catch (_) {
        // El seguimiento ya se guardo en el backend; no se revierte la interfaz.
      }

      widget.onSeguimientoChanged?.call(
        widget.organizacion.copyWith(
          esSeguidor: _siguiendo,
          cantidadSeguidores: _seguidores,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _siguiendo
                  ? 'Ahora sigues a ${widget.organizacion.nombre}'
                  : 'Dejaste de seguir a ${widget.organizacion.nombre}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String mensaje = 'Error al actualizar: $e';
      if (e.toString().contains('400') || e.toString().toLowerCase().contains('propia organización')) {
        mensaje = 'No puedes seguir a tu propia organización';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actualizandoSeguimiento = false);
      }
    }
  }

  Future<void> _abrirComentarios(Publicacion publicacion) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ComentariosScreen(publicacion: publicacion),
      ),
    );
  }

  void _toggleMeGusta(Publicacion publicacion) {
    setState(() {
      final index = _publicaciones.indexWhere((p) => p.id == publicacion.id);
      if (index != -1) {
        final p = _publicaciones[index];
        _publicaciones[index] = p.copyWith(
          leGustaAlUsuario: !p.leGustaAlUsuario,
          meGusta: p.meGusta + (p.leGustaAlUsuario ? -1 : 1),
        );
      }
    });
    context.read<ForoBloc>().add(ForoMeGustaCambiado(publicacion.id));
  }

  Future<void> _subirImagenBackend({
    required File archivo,
    required bool esPortada,
  }) async {
    setState(() => _subiendoImagen = true);

    try {
      final dio = context.read<Dio>();
      final formData = FormData.fromMap({
        esPortada ? 'foto_portada' : 'foto_perfil':
            await MultipartFile.fromFile(
          archivo.path,
          filename: esPortada ? 'portada.jpg' : 'perfil.jpg',
        ),
      });

      final response = await dio.patch(
        '/usuarios/mi-organizacion/imagenes',
        data: formData,
      );

      if (!mounted) return;

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          if (esPortada) {
            _portadaUrl = data['fotoPortada']?.toString() ??
                data['foto_portada']?.toString() ??
                _portadaUrl;
            _portadaFile = null;
          } else {
            _logoUrl = data['logoUrl']?.toString() ??
                data['logo_url']?.toString() ??
                data['fotoPerfil']?.toString() ??
                data['foto_perfil']?.toString() ??
                _logoUrl;
            _perfilFile = null;
          }
          _subiendoImagen = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${esPortada ? "Portada" : "Foto de perfil"} actualizada correctamente',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _subiendoImagen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir la imagen: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _elegirImagen({required bool esPortada}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).inputDecorationTheme.fillColor ??
                Theme.of(sheetContext).colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                esPortada ? 'Cambiar portada' : 'Cambiar foto de perfil',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _FuenteImagen(
                  icono: Icons.camera_alt,
                  titulo: 'Tomar fotografia',
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: _FuenteImagen(
                  icono: Icons.photo_library,
                  titulo: 'Seleccionar de galeria',
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    final imagen = await _picker.pickImage(
      source: source,
      maxWidth: esPortada ? 1800 : 900,
      maxHeight: esPortada ? 1000 : 900,
      imageQuality: 85,
    );
    if (imagen == null || !mounted) return;

    await _subirImagenBackend(
      archivo: File(imagen.path),
      esPortada: esPortada,
    );
  }

  Future<void> _guardarDescripcionBackend(String nuevaDescripcion) async {
    setState(() => _guardandoDescripcion = true);
    try {
      final dio = context.read<Dio>();
      final response = await dio.patch(
        '/usuarios/mi-organizacion',
        data: {'descripcion': nuevaDescripcion},
      );

      if (!mounted) return;
      setState(() {
        _descripcion = nuevaDescripcion;
        _guardandoDescripcion = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descripcion actualizada correctamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardandoDescripcion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la descripcion: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editarDescripcion() async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (_) => _EditarDescripcionDialog(inicial: _descripcion),
    );

    if (!mounted) return;
    if (resultado != null && resultado.trim().isNotEmpty) {
      await _guardarDescripcionBackend(resultado.trim());
    }
  }

  void _editarPublicacion(Publicacion publicacion) {
    final controller = TextEditingController(text: publicacion.contenido);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar publicacion'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 300,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Contenido',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ForoBloc>().add(
                ForoPublicacionEditada(
                  publicacionId: publicacion.id,
                  titulo: publicacion.titulo,
                  contenido: controller.text,
                  categoria: publicacion.categoria,
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publicacion actualizada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarPublicacion(Publicacion publicacion) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar publicacion'),
        content: const Text(
          'Estas seguro de que deseas eliminar esta publicacion? Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ForoBloc>().add(ForoPublicacionEliminada(publicacion.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publicacion eliminada')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avance = widget.organizacion.metaMensual > 0
        ? (widget.organizacion.recaudadoMensual / widget.organizacion.metaMensual).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_portadaFile != null)
                        Image.file(_portadaFile!, fit: BoxFit.cover)
                      else if (_portadaUrl.isNotEmpty)
                        Image.network(
                          _portadaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colors.primary.withValues(alpha: .15),
                          ),
                        )
                      else
                        Container(
                          color: colors.primary.withValues(alpha: .15),
                          child: Icon(Icons.pets_rounded, color: colors.primary.withValues(alpha: .5), size: 48),
                        ),
                      if (_esDueno)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _subiendoImagen
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                )
                              : Material(
                                  color: Colors.black45,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => _elegirImagen(esPortada: true),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: colors.surface,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: colors.primaryContainer,
                                backgroundImage: _perfilFile != null
                                    ? FileImage(_perfilFile!)
                                    : (_logoUrl.isNotEmpty ? NetworkImage(_logoUrl) : null),
                                child: _perfilFile == null && _logoUrl.isEmpty
                                    ? Icon(Icons.pets_rounded, color: colors.primary)
                                    : null,
                              ),
                            ),
                            if (_esDueno)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: _subiendoImagen
                                    ? const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                      )
                                    : Material(
                                        color: colors.primary,
                                        shape: const CircleBorder(),
                                        elevation: 2,
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: () => _elegirImagen(esPortada: false),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                              ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -38),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: _esDueno ? _editarDescripcion : null,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        widget.organizacion.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: _esDueno ? colors.primary : null,
                                          decoration: _esDueno ? TextDecoration.underline : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const OrganizacionVerificadaBadge(size: 20),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_seguidores seguidores',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            if (!_esDueno)
                              SizedBox(
                                width: 220,
                                child: _actualizandoSeguimiento
                                    ? OutlinedButton.icon(
                                        onPressed: null,
                                        icon: const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        label: const Text('Actualizando...'),
                                      )
                                    : _siguiendo
                                    ? OutlinedButton.icon(
                                        onPressed: _toggleSeguir,
                                        icon: const Icon(Icons.check_rounded, size: 18),
                                        label: const Text('Siguiendo'),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _toggleSeguir,
                                        icon: const Icon(Icons.add_rounded, size: 18),
                                        label: const Text('Seguir'),
                                      ),
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
          const SizedBox(height: 14),

          _Seccion(
            titulo: 'Acerca de la organizacion',
            trailing: _esDueno
                ? IconButton(
                    tooltip: 'Editar descripcion',
                    onPressed: _guardandoDescripcion ? null : _editarDescripcion,
                    icon: _guardandoDescripcion
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.edit_outlined, color: colors.primary, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_descripcion.isEmpty ? 'Sin descripcion' : _descripcion),
                if (widget.organizacion.tiposAnimales != null) ...[
                  const SizedBox(height: 8),
                  _Dato(icono: Icons.pets_outlined, texto: widget.organizacion.tiposAnimales!),
                ],
                if (widget.organizacion.telefonoEmergencia != null) ...[
                  const SizedBox(height: 6),
                  _Dato(icono: Icons.phone_outlined, texto: widget.organizacion.telefonoEmergencia!),
                ],
                if (widget.organizacion.correoInstitucional != null) ...[
                  const SizedBox(height: 6),
                  _Dato(icono: Icons.email_outlined, texto: widget.organizacion.correoInstitucional!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          _Seccion(
            titulo: 'Meta del mes de donaciones',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${widget.organizacion.recaudadoMensual.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.primary),
                ),
                Text(
                  'de \$${widget.organizacion.metaMensual.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: avance,
                    minHeight: 10,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(avance * 100).toStringAsFixed(0)}% de la meta alcanzada',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Publicaciones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          
          if (_cargandoPublicaciones)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_publicaciones.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Esta organizacion aun no publica.')),
            )
          else
            for (final publicacion in _publicaciones)
              _PublicacionConOrg(
                publicacion: publicacion,
                mapaOrgs: _mapaOrgs,
                onMeGusta: () => _toggleMeGusta(publicacion),
                onComentarios: () => _abrirComentarios(publicacion),
                onEditar: _esDueno ? () => _editarPublicacion(publicacion) : null,
                onEliminar: _esDueno ? () => _eliminarPublicacion(publicacion) : null,
              ),
        ],
      ),
    );
  }
}

class _PublicacionConOrg extends StatelessWidget {
  final Publicacion publicacion;
  final Map<int, OrganizacionForo> mapaOrgs;
  final VoidCallback onMeGusta;
  final VoidCallback onComentarios;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const _PublicacionConOrg({
    required this.publicacion,
    required this.mapaOrgs,
    required this.onMeGusta,
    required this.onComentarios,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final org = publicacion.usuarioId != null ? mapaOrgs[publicacion.usuarioId] : null;
    final esOrg = org != null;
    
    final publicacionAMostrar = esOrg && org!.nombre.isNotEmpty
        ? publicacion.copyWith(
            nombreUsuario: org.nombre,
            fotoUsuarioUrl: org.logoUrl.isNotEmpty ? org.logoUrl : publicacion.fotoUsuarioUrl,
          )
        : publicacion;

    return PublicacionCard(
      publicacion: publicacionAMostrar,
      avatarUrl: publicacionAMostrar.fotoUsuarioUrl,
      autorVerificado: esOrg,
      onMeGusta: onMeGusta,
      onComentarios: onComentarios,
      onEditar: onEditar,
      onEliminar: onEliminar,
    );
  }
}

class _PasoBienvenida extends StatelessWidget {
  final int numero;
  final String texto;
  final IconData icono;

  const _PasoBienvenida({
    required this.numero,
    required this.texto,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$numero',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icono, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditarDescripcionDialog extends StatefulWidget {
  final String inicial;

  const _EditarDescripcionDialog({required this.inicial});

  @override
  State<_EditarDescripcionDialog> createState() =>
      _EditarDescripcionDialogState();
}

class _EditarDescripcionDialogState extends State<_EditarDescripcionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.inicial;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _guardar() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(_controller.text);
  }

  void _cancelar() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Editar descripcion'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 300,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Descripcion de la organizacion',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancelar,
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _FuenteImagen extends StatelessWidget {
  const _FuenteImagen({
    required this.icono,
    required this.titulo,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icono, color: colors.primary),
      title: Text(titulo),
      onTap: onTap,
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  final Widget? trailing;

  const _Seccion({
    required this.titulo,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(child: Text(texto)),
      ],
    );
  }
}
