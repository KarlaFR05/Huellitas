import 'package:flutter/material.dart';

Future<void> showFullScreenImage(
  BuildContext context, {
  required Widget image,
  String semanticLabel = 'Imagen ampliada',
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                image: true,
                label: semanticLabel,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Center(child: image),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
