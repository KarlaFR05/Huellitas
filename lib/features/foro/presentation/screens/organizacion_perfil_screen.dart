import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/organizacion_foro.dart';
import '../../domain/entities/publicacion.dart';
import '../widgets/publicacion_card.dart';

class OrganizacionPerfilScreen extends StatefulWidget {
  final OrganizacionForo organizacion;
  final List<Publicacion> publicaciones;

  const OrganizacionPerfilScreen({
    super.key,
    required this.organizacion,
    this.publicaciones = const [],
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

  // ✅ Permisos
  bool _esDueno = false;
  bool _esOrganizacionActual = false;

  final _picker = ImagePicker();
  File? _perfilFile;
  File? _portadaFile;

  @override
  void initState() {
    super.initState();
    _descripcion = widget.organizacion.descripcion;
    _logoUrl = widget.organizacion.logoUrl;
    _portadaUrl = widget.organizacion.fotoPortada;
    _siguiendo = widget.organizacion.esSeguidor;
    _seguidores = widget.organizacion.cantidadSeguidores;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.data is Usuario) {
      final usuario = authState.data as Usuario;
      _esDueno = widget.organizacion.usuarioId == usuario.usuarioIdPk;
      _esOrganizacionActual = usuario.esOrganizacion;
    }
  }

  void _toggleSeguir() {
    setState(() {
      _siguiendo = !_siguiendo;
      _seguidores += _siguiendo ? 1 : -1;
    });
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
            color:
                Theme.of(sheetContext).inputDecorationTheme.fillColor ??
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
                  titulo: 'Tomar fotografía',
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: _FuenteImagen(
                  icono: Icons.photo_library,
                  titulo: 'Seleccionar de galería',
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.gallery),
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

    setState(() {
      if (esPortada) {
        _portadaFile = File(imagen.path);
      } else {
        _perfilFile = File(imagen.path);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${esPortada ? "Portada" : "Foto de perfil"} seleccionada. Listo para subir cuando el backend esté conectado.',
          ),
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
      setState(() => _descripcion = resultado.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descripción actualizada correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avance = widget.organizacion.metaMensual > 0
        ? (widget.organizacion.recaudadoMensual /
                widget.organizacion.metaMensual)
            .clamp(0.0, 1.0)
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
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .45),
              ),
            ),
            child: Column(
              children: [
                // PORTADA
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
                          child: Icon(
                            Icons.pets_rounded,
                            color: colors.primary.withValues(alpha: .5),
                            size: 48,
                          ),
                        ),
                      // ✅ Cámara de portada: SOLO dueño
                      if (_esDueno)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.black45,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _elegirImagen(esPortada: true),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
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
                                    : (_logoUrl.isNotEmpty
                                        ? NetworkImage(_logoUrl)
                                        : null),
                                child: _perfilFile == null && _logoUrl.isEmpty
                                    ? Icon(
                                        Icons.pets_rounded,
                                        color: colors.primary,
                                      )
                                    : null,
                              ),
                            ),
                            // ✅ Cámara de logo: SOLO dueño
                            if (_esDueno)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Material(
                                  color: colors.primary,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () =>
                                        _elegirImagen(esPortada: false),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
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
                                  child: Text(
                                    widget.organizacion.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
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
                            // ✅ Botón Seguir: SOLO usuarios normales (no dueño, no organización)
                            if (!_esDueno && !_esOrganizacionActual)
                              SizedBox(
                                width: 220,
                                child: _siguiendo
                                    ? OutlinedButton.icon(
                                        onPressed: _toggleSeguir,
                                        icon: const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Siguiendo'),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _toggleSeguir,
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                        ),
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

          // ACERCA DE (lápiz solo dueño)
          _Seccion(
            titulo: 'Acerca de la organización',
            trailing: _esDueno
                ? IconButton(
                    tooltip: 'Editar descripción',
                    onPressed: _editarDescripcion,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colors.primary,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_descripcion),
                if (widget.organizacion.tiposAnimales != null) ...[
                  const SizedBox(height: 8),
                  _Dato(
                    icono: Icons.pets_outlined,
                    texto: widget.organizacion.tiposAnimales!,
                  ),
                ],
                if (widget.organizacion.telefonoEmergencia != null) ...[
                  const SizedBox(height: 6),
                  _Dato(
                    icono: Icons.phone_outlined,
                    texto: widget.organizacion.telefonoEmergencia!,
                  ),
                ],
                if (widget.organizacion.correoInstitucional != null) ...[
                  const SizedBox(height: 6),
                  _Dato(
                    icono: Icons.email_outlined,
                    texto: widget.organizacion.correoInstitucional!,
                  ),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.publicaciones.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Esta organización aún no publica.')),
            )
          else
            for (final publicacion in widget.publicaciones)
              PublicacionCard(
                publicacion: publicacion,
                avatarUrl: publicacion.fotoUsuarioUrl,
                autorVerificado: widget.organizacion.verificada,
                onMeGusta: () {},
                onComentarios: () {},
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
      title: const Text('Editar descripción'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 300,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Descripción de la organización',
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