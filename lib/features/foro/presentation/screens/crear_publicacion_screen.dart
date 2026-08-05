import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar fotografía'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Seleccionar de galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
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
        setState(() => _imagen = File(seleccionada.path));
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
                const CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/images/avatares/avatar_01.png',
                  ),
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
            if (_imagen != null) ...[
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      _imagen!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      onPressed: _publicando
                          ? null
                          : () => setState(() => _imagen = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Material(
              color: colors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: colors.primary,
                ),
                title: Text(
                  _imagen == null ? 'Agregar fotografía' : 'Cambiar fotografía',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _publicando ? null : _seleccionarImagen,
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
