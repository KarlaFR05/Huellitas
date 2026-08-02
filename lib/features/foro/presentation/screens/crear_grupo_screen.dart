import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/grupo.dart';

class CrearGrupoScreen extends StatefulWidget {
  const CrearGrupoScreen({super.key, this.grupo});

  final Grupo? grupo;

  @override
  State<CrearGrupoScreen> createState() => _CrearGrupoScreenState();
}

class _CrearGrupoScreenState extends State<CrearGrupoScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _picker = ImagePicker();
  File? _perfil;
  File? _portada;
  bool _guardando = false;
  PrivacidadGrupo _privacidad = PrivacidadGrupo.publico;

  bool get _editando => widget.grupo != null;

  @override
  void initState() {
    super.initState();
    final grupo = widget.grupo;
    if (grupo != null) {
      _nombreController.text = grupo.nombre;
      _descripcionController.text = grupo.descripcion;
      _privacidad = grupo.privacidad;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen({required bool esPortada}) async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: esPortada ? 1800 : 900,
      maxHeight: esPortada ? 1000 : 900,
      imageQuality: 85,
    );
    if (imagen == null || !mounted) return;
    setState(() {
      if (esPortada) {
        _portada = File(imagen.path);
      } else {
        _perfil = File(imagen.path);
      }
    });
  }

  Future<void> _crear() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    if (nombre.length < 3 || descripcion.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escribe un nombre y una descripción de al menos 10 caracteres',
          ),
        ),
      );
      return;
    }
    setState(() => _guardando = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.pop(context, {
      'nombre': nombre,
      'descripcion': descripcion,
      'perfilPath': _perfil?.path,
      'portadaPath': _portada?.path,
      'privacidad': _privacidad,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar grupo' : 'Crear grupo'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _crear,
            child: Text(
              _editando ? 'Guardar' : 'Crear',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    bottom: 26,
                    child: Material(
                      color: colors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _guardando
                            ? null
                            : () => _elegirImagen(esPortada: true),
                        child: _portada == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: colors.primary,
                                    size: 34,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('Agregar portada'),
                                ],
                              )
                            : Image.file(_portada!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _guardando
                          ? null
                          : () => _elegirImagen(esPortada: false),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: colors.surface,
                        child: CircleAvatar(
                          radius: 43,
                          backgroundColor: colors.primaryContainer,
                          backgroundImage: _perfil == null
                              ? null
                              : FileImage(_perfil!),
                          child: _perfil == null
                              ? Icon(
                                  Icons.add_a_photo_outlined,
                                  color: colors.primary,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nombreController,
              enabled: !_guardando,
              maxLength: 50,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              enabled: !_guardando,
              minLines: 4,
              maxLines: 7,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'Cuenta de qué trata esta comunidad',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Privacidad',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    selected: _privacidad == PrivacidadGrupo.publico,
                    avatar: const Icon(Icons.public_rounded, size: 18),
                    label: const Text('Público'),
                    onSelected: _guardando
                        ? null
                        : (_) => setState(
                            () => _privacidad = PrivacidadGrupo.publico,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    selected: _privacidad == PrivacidadGrupo.privado,
                    avatar: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: const Text('Privado'),
                    onSelected: _guardando
                        ? null
                        : (_) => setState(
                            () => _privacidad = PrivacidadGrupo.privado,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _privacidad == PrivacidadGrupo.publico
                  ? 'Cualquier usuario puede unirse inmediatamente.'
                  : 'Las solicitudes deberán ser aceptadas por el administrador.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Serás el administrador del grupo. Los demás usuarios se registrarán como miembros.',
                  ),
                ),
              ],
            ),
            if (_guardando) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
