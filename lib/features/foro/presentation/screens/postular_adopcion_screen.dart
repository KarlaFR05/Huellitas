import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/adopcion.dart';
import '../../domain/entities/pregunta_adopcion.dart';
import '../../data/repositories/adopciones_repository.dart';

class PostularAdopcionScreen extends StatefulWidget {
  const PostularAdopcionScreen({
    super.key,
    required this.adopcion,
    required this.nombreUsuario,
  });

  final Adopcion adopcion;
  final String nombreUsuario;

  @override
  State<PostularAdopcionScreen> createState() => _PostularAdopcionScreenState();
}

class _PostularAdopcionScreenState extends State<PostularAdopcionScreen> {
  late final List<PreguntaAdopcion> _preguntas;
  late final List<TextEditingController> _controllers;
  late final TextEditingController _contactoController;

  @override
  void initState() {
    super.initState();

    _preguntas = widget.adopcion.preguntas
        .where((pregunta) => !pregunta.esMedioContacto)
        .toList();
    _controllers = [for (final _ in _preguntas) TextEditingController()];

    final authState = context.read<AuthBloc>().state;
    final usuario = authState is AuthSuccess && authState.data is Usuario
        ? authState.data as Usuario
        : null;
    _contactoController = TextEditingController(
      text: usuario == null
          ? ''
          : usuario.numTelefono.trim().isNotEmpty
          ? usuario.numTelefono.trim()
          : usuario.correo.trim(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _contactoController.dispose();

    super.dispose();
  }

  bool get _todasRespondidas {
    return _contactoController.text.trim().isNotEmpty &&
        _controllers.every((controller) => controller.text.trim().isNotEmpty);
  }

  Future<void> _continuar() async {
    if (!_todasRespondidas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Responde todas las preguntas antes de continuar.'),
        ),
      );
      return;
    }

    if (_preguntas.any((pregunta) => pregunta.id == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta adopción todavía no tiene preguntas listas para responder.',
          ),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Confirmar solicitud'),
          content: const Text(
            '¿Estás seguro de que quieres enviar '
            'tu solicitud para adoptar esta mascota?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Enviar solicitud'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final usuario = authState is AuthSuccess && authState.data is Usuario
        ? authState.data as Usuario
        : null;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para postularte.')),
      );
      return;
    }

    try {
      await context.read<AdopcionesRepository>().crearPostulacion(
        adopcionId: widget.adopcion.id,
        usuarioId: usuario.usuarioIdPk,
        contacto: _contactoController.text.trim(),
        respuestas: {
          for (var i = 0; i < _preguntas.length; i++)
            _preguntas[i].id!: _controllers[i].text.trim(),
        },
      );
    } catch (e) {
      if (!mounted) return;
      String mensaje = 'No se pudo enviar tu solicitud.';
      if (e is DioException && e.response?.data is Map) {
        mensaje = (e.response!.data as Map)['detail']?.toString() ?? mensaje;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        icon: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade700,
            size: 50,
          ),
        ),
        title: const Text(
          '¡Postulación enviada!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Tu solicitud para adoptar a ${widget.adopcion.nombre} fue enviada '
          'correctamente. El responsable podrá revisarla y te notificaremos '
          'cuando haya una decisión.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext),
            icon: const Icon(Icons.pets_rounded),
            label: const Text('Volver a adopciones'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitud de adopción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiero adoptar a ${widget.adopcion.nombre}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 8),

            Text(
              'Queremos conocerte un poco mejor antes '
              'de enviar tu solicitud.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 24),

            // Información de la mascota
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets_rounded, size: 30, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.adopcion.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.adopcion.especie} · '
                          '${widget.adopcion.edad} · '
                          '${widget.adopcion.ciudad}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Medio de contacto',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Precargamos el número o correo registrado en la app. '
                      'Puedes conservarlo o reemplazarlo por cualquier otro '
                      'medio de contacto. Solo será visible si eres seleccionado.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _contactoController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Teléfono, WhatsApp o correo',
                hintText: 'Ej. 55 1234 5678',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 28),

            Text(
              'Cuéntanos sobre ti',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 6),

            Text(
              'Responde las siguientes preguntas.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 18),

            for (var i = 0; i < _preguntas.length; i++) ...[
              Text(
                '${i + 1}. ${_preguntas[i].texto}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _controllers[i],
                minLines: 3,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _todasRespondidas ? _continuar : null,
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
