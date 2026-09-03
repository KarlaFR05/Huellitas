import 'package:flutter/material.dart';

const _colorInfoBg = Color(0xFFFCEFD2);
const _colorInfoBorde = Color(0xFFE8C87A);
const _colorInfoTexto = Color(0xFF6B4E16);

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'Buscando posibles duplicados...',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _colorInfoBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _colorInfoBorde),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: _colorInfoTexto),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Comparamos tu reporte con otros cercanos para evitar duplicados',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: _colorInfoTexto,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
