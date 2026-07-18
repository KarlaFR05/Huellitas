import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FotoCard extends StatefulWidget {
  final String titulo;
  final ValueChanged<File> onImageSelected;

  const FotoCard({
    super.key,
    required this.titulo,
    required this.onImageSelected,
  });

  @override
  State<FotoCard> createState() => _FotoCardState();
}

class _FotoCardState extends State<FotoCard> {
  final ImagePicker _picker = ImagePicker();

  File? _imagen;

  Future<void> _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (foto == null) return;

    final file = File(foto.path);

    setState(() {
      _imagen = file;
    });

    widget.onImageSelected(file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tomarFoto,
      child: Container(
        width: double.infinity,
        height: 180,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              Theme.of(context).inputDecorationTheme.fillColor ??
              Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: _imagen == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 45,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _imagen!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}
