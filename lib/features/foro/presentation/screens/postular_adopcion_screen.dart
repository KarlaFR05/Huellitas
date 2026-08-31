import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../insignias/data/repositories/insignia_repository_impl.dart';
import '../../../insignias/domain/entities/categoria_insignia.dart';
import '../../../insignias/domain/entities/insignia.dart';
import '../../domain/entities/adopcion.dart';
import '../adopciones_postulaciones_store.dart';

class PostularAdopcionScreen extends StatefulWidget {
  const PostularAdopcionScreen({
    super.key,
    required this.adopcion,
    required this.nombreUsuario,
  });

  final Adopcion adopcion;
  final String nombreUsuario;

  @override
  State<PostularAdopcionScreen> createState() =>
      _PostularAdopcionScreenState();
}

class _PostularAdopcionScreenState
    extends State<PostularAdopcionScreen> {
  late final List<TextEditingController> _controllers;
  final _contactoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controllers = [
      for (final _ in widget.adopcion.preguntas)
        TextEditingController(),
    ];
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
    return _contactoController.text.trim().isNotEmpty && _controllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
  }

  Future<void> _continuar() async {
    if (!_todasRespondidas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Responde todas las preguntas antes de continuar.',
          ),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirmar solicitud',
          ),
          content: const Text(
            '¿Estás seguro de que quieres enviar '
            'tu solicitud para adoptar esta mascota?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Enviar solicitud'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    final auth = context.read<AuthBloc>().state;
    final usuario = auth is AuthSuccess && auth.data is Usuario
        ? auth.data as Usuario
        : null;
    final resumen = await _obtenerResumenPostulante(usuario);
    if (!mounted) return;

    PostulacionesAdopcionStore.agregar(
      widget.adopcion.id,
      PostulacionAdopcion(
        nombre: widget.nombreUsuario,
        respuestas: {
          for (var i = 0;
              i < widget.adopcion.preguntas.length;
              i++)
            widget.adopcion.preguntas[i]:
                _controllers[i].text.trim(),
        },
        usuarioId: usuario?.usuarioIdPk,
        fechaRegistro: usuario?.fechaRegistroUsuario,
        ubicacion: _ubicacionUsuario(usuario),
        insigniasRescate: resumen.insigniasRescate,
        insigniasReporte: resumen.insigniasReporte,
        insigniasDonacion: resumen.insigniasDonacion,
        porcentajeAptitud: resumen.porcentajeAptitud,
        fotoPerfil: usuario?.fotoPerfil,
        contacto: _contactoController.text.trim(),
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu solicitud fue enviada correctamente.',
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  String? _ubicacionUsuario(Usuario? usuario) {
    if (usuario == null) return null;
    final ubicacion = [usuario.ciudad, usuario.estado]
        .whereType<String>()
        .where((valor) => valor.trim().isNotEmpty)
        .join(', ');
    return ubicacion.isEmpty ? null : ubicacion;
  }

  Future<_ResumenPostulante> _obtenerResumenPostulante(Usuario? usuario) async {
    if (usuario == null) return const _ResumenPostulante();
    try {
      final insignias = await context
          .read<InsigniaRepositoryImpl>()
          .obtenerTodasLasInsignias(usuario.usuarioIdPk)
          .catchError((_) => <CategoriaInsignia, List<Insignia>>{});
      final rescates = (insignias[CategoriaInsignia.rescate] ?? const [])
            .where((insignia) => insignia.obtenida == true)
            .length;
      final donaciones = (insignias[CategoriaInsignia.donacion] ?? const [])
          .where((insignia) => insignia.obtenida == true)
          .length;
      final reportes = (insignias[CategoriaInsignia.reporte] ?? const [])
          .where((insignia) => insignia.obtenida == true)
          .length;
      return _ResumenPostulante(
        insigniasRescate: rescates,
        insigniasReporte: reportes,
        insigniasDonacion: donaciones,
        porcentajeAptitud: _porcentajePorInsignias(
          rescates,
          reportes,
          donaciones,
        ),
      );
    } catch (_) {
      return const _ResumenPostulante();
    }
  }

  int _porcentajePorInsignias(
    int rescates,
    int reportes,
    int donaciones,
  ) {
    const totalInsignias = 21;
    final insigniasObtenidas = rescates + reportes + donaciones;
    return ((insigniasObtenidas / totalInsignias) * 100)
        .round()
        .clamp(0, 100)
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitud de adopción',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Quiero adoptar a ${widget.adopcion.nombre}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Queremos conocerte un poco mejor antes '
              'de enviar tu solicitud.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Información de la mascota
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 30,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              'Responde las siguientes preguntas.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Datos de contacto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '¿Cómo puede contactarte la persona que da en adopción? Solo se compartirá si eres aceptado.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono o medio de contacto',
                hintText: 'Ej. 55 1234 5678 o correo@ejemplo.com',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            for (var i = 0;
                i < widget.adopcion.preguntas.length;
                i++) ...[
              Text(
                widget.adopcion.preguntas[i],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _controllers[i],
                minLines: 3,
                maxLines: 6,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'Escribe tu respuesta...',
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
                onPressed: _todasRespondidas
                    ? _continuar
                    : null,
                icon: const Icon(
                  Icons.send_rounded,
                ),
                label: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenPostulante {
  const _ResumenPostulante({
    this.insigniasRescate = 0,
    this.insigniasReporte = 0,
    this.insigniasDonacion = 0,
    this.porcentajeAptitud = 0,
  });

  final int insigniasRescate;
  final int insigniasReporte;
  final int insigniasDonacion;
  final int porcentajeAptitud;
}
