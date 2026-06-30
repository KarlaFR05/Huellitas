import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

class CompletarPerfilDialog extends StatefulWidget {
  const CompletarPerfilDialog({super.key});

  @override
  State<CompletarPerfilDialog> createState() =>
      _CompletarPerfilDialogState();
}

class _CompletarPerfilDialogState
    extends State<CompletarPerfilDialog> {
  bool acepto = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Completa tu perfil',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para brindar mayor seguridad a la comunidad de Huellitas es necesario verificar tu identidad.',
            ),

            const SizedBox(height: 18),

            const Text(
              'Durante este proceso se solicitará:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Row(
              children: [
                Icon(Icons.location_on_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Dirección'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.badge_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Identificación oficial'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.face_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Selfie para validación'),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'La información será utilizada únicamente para verificar tu identidad y mantener un entorno seguro para todos los usuarios. No será compartida con terceros salvo obligación legal.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: acepto,
                  onChanged: (value) {
                    setState(() {
                      acepto = value ?? false;
                    });
                  },
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'He leído y acepto la ',
                          ),
                          TextSpan(
                            text: 'Política de Privacidad',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration:
                                  TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push('/privacidad');
                                  },
                          ),
                          const TextSpan(
                            text:
                                ', autorizando el tratamiento de mis datos personales para la verificación de identidad y el funcionamiento de Huellitas.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),

        ElevatedButton(
          onPressed: acepto
              ? () {
                  Navigator.pop(context);
                  context.push('/completar-perfil');
                }
              : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}