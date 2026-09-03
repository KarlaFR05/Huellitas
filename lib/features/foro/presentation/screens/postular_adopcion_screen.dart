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

  @override
  void initState() {
    super.initState();

    _preguntas = [
      ...widget.adopcion.preguntas.where(
        (pregunta) => pregunta.esMedioContacto,
      ),
      ...widget.adopcion.preguntas.where(
        (pregunta) => !pregunta.esMedioContacto,
      ),
    ];
    _controllers = [for (final _ in _preguntas) TextEditingController()];

    final authState = context.read<AuthBloc>().state;
    final usuario = authState is AuthSuccess && authState.data is Usuario
        ? authState.data as Usuario
        : null;
    if (_preguntas.isNotEmpty &&
        _preguntas.first.esMedioContacto &&
        usuario != null) {
      _controllers.first.text = usuario.numTelefono.trim().isNotEmpty
          ? usuario.numTelefono.trim()
          : usuario.correo.trim();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  bool get _todasRespondidas {
    return _controllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu solicitud fue enviada correctamente.')),
    );

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
                minLines: _preguntas[i].esMedioContacto ? 1 : 3,
                maxLines: _preguntas[i].esMedioContacto ? 2 : 6,
                keyboardType: _preguntas[i].esMedioContacto
                    ? TextInputType.text
                    : TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _preguntas[i].esMedioContacto
                      ? 'Teléfono, WhatsApp o correo electrónico'
                      : 'Escribe tu respuesta...',
                  helperText: _preguntas[i].esMedioContacto
                      ? 'Solo se utilizará para coordinar la adopción si eres seleccionado.'
                      : null,
                  border: const OutlineInputBorder(),
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
