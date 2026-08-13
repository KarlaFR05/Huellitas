import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/avatar_helper.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/publicacion.dart';

class CrearPublicacionScreen extends StatefulWidget {
  const CrearPublicacionScreen({super.key, this.publicacion});

  final Publicacion? publicacion;

  @override
  State<CrearPublicacionScreen> createState() => _CrearPublicacionScreenState();
}

class _CrearPublicacionScreenState extends State<CrearPublicacionScreen> {
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _imagen;
  String? _imagenExistenteUrl;
  bool _publicando = false;
  CategoriaPublicacion _categoria = CategoriaPublicacion.adopcion;

  bool get _editando => widget.publicacion != null;

  @override
  void initState() {
    super.initState();
    final publicacion = widget.publicacion;
    if (publicacion != null) {
      _tituloController.text = publicacion.titulo;
      _contenidoController.text = publicacion.contenido;
      _categoria = publicacion.categoria;
      _imagenExistenteUrl = publicacion.imagenUrl;
    }
  }

  static const _categorias = <(CategoriaPublicacion, String, IconData)>[
    (CategoriaPublicacion.adopcion, 'Adopción', Icons.pets_rounded),
    (CategoriaPublicacion.vacunacion, 'Vacunación', Icons.vaccines_rounded),
    (CategoriaPublicacion.salud, 'Salud', Icons.health_and_safety_rounded),
    (CategoriaPublicacion.extraviados, 'Extraviados', Icons.search_rounded),
    (
      CategoriaPublicacion.alimentacion,
      'Alimentación',
      Icons.restaurant_rounded,
    ),
    (CategoriaPublicacion.entrenamiento, 'Entrenamiento', Icons.school_rounded),
    (CategoriaPublicacion.cuidado, 'Cuidado', Icons.favorite_rounded),
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colors.primary),
                  title: const Text('Tomar fotografía'),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ImageSource.camera,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: colors.primary),
                  title: const Text('Seleccionar de galería'),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) return;
    try {
      final seleccionada = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (seleccionada != null && mounted) {
        setState(() {
          _imagen = File(seleccionada.path);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo seleccionar la imagen')),
        );
      }
    }
  }

  Future<void> _publicar() async {
    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();
    if (titulo.isEmpty || contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título y una descripción')),
      );
      return;
    }
    setState(() => _publicando = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context, {
      'titulo': titulo,
      'contenido': contenido,
      'imagen': _imagen,
      'categoria': _categoria,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final usuario = authState is AuthSuccess && authState.data is Usuario
        ? authState.data as Usuario
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar publicación' : 'Crear publicación'),
        actions: [
          TextButton(
            onPressed: _publicando ? null : _publicar,
            child: Text(
              _editando ? 'Guardar' : 'Publicar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de publicación',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final categoria in _categorias)
                  ChoiceChip(
                    selected: _categoria == categoria.$1,
                    avatar: Icon(categoria.$3, size: 18),
                    label: Text(categoria.$2),
                    onSelected: _publicando
                        ? null
                        : (_) => setState(() => _categoria = categoria.$1),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _tituloController,
              enabled: !_publicando,
              maxLength: 50,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: avatarProvider(usuario?.fotoPerfil),
                  child: usuario?.fotoPerfil == null
                      ? Icon(Icons.person_rounded, color: colors.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contenidoController,
                    enabled: !_publicando,
                    minLines: 5,
                    maxLines: 12,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '¿Qué deseas compartir?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            if (_imagen != null || _imagenExistenteUrl != null) ...[
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _imagen != null
                        ? Image.file(
                            _imagen!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _imagenExistenteUrl!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 250,
                              color: colors.surfaceContainerHighest,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _imagen == null && _imagenExistenteUrl == null
                  ? 'Adjuntar fotografía'
                  : 'Cambiar fotografía',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _publicando ? null : _seleccionarImagen,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: .1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _imagen == null && _imagenExistenteUrl == null
                              ? Icons.add_a_photo_outlined
                              : Icons.change_circle_outlined,
                          size: 34,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imagen == null && _imagenExistenteUrl == null
                            ? 'Toca para agregar una foto'
                            : 'Toca para elegir otra foto',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cámara o galería · Máximo 1 imagen',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_publicando) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
