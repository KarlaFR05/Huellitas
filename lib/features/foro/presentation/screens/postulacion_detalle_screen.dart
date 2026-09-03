import 'package:flutter/material.dart';

import '../adopciones_postulaciones_store.dart';

class PostulacionDetalleScreen extends StatelessWidget {
  const PostulacionDetalleScreen({
    super.key,
    required this.postulacion,
  });

  final PostulacionAdopcion postulacion;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final porcentaje = postulacion.porcentajeAptitud;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Respuestas de adopción',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        children: [
          // Postulante
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: colors.primary,
                  child: Text(
                    postulacion.nombre.isNotEmpty
                        ? postulacion.nombre[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        postulacion.nombre,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Nivel de aptitud: $porcentaje%',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),

                      const SizedBox(height: 7),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _colorAptitud(
                            porcentaje,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          _textoAptitud(porcentaje),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _colorAptitud(porcentaje),
                      width: 6,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$porcentaje%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Respuestas del postulante',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),

          const SizedBox(height: 12),

          // Respuestas
          for (final respuesta
              in postulacion.respuestas.entries)
            _RespuestaCard(
              pregunta: respuesta.key,
              respuesta: respuesta.value,
            ),

          const SizedBox(height: 20),

          // Entrevista
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  postulacion.entrevistaCompletada
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  color:
                      postulacion.entrevistaCompletada
                          ? Colors.green
                          : colors.primary,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    postulacion.entrevistaCompletada
                        ? 'Entrevista completada'
                        : 'Entrevista pendiente',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
              },
              child: const Text(
                'Aprobar adopción',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _textoAptitud(int porcentaje) {
    if (porcentaje >= 85) {
      return 'Muy apta';
    }

    if (porcentaje >= 70) {
      return 'Apta';
    }

    return 'En evaluación';
  }

  Color _colorAptitud(int porcentaje) {
    if (porcentaje >= 85) {
      return Colors.green;
    }

    if (porcentaje >= 70) {
      return Colors.orange;
    }

    return Colors.grey;
  }
}
class _RespuestaCard extends StatefulWidget {
  const _RespuestaCard({
    required this.pregunta,
    required this.respuesta,
  });

  final String pregunta;
  final String respuesta;

  @override
  State<_RespuestaCard> createState() =>
      _RespuestaCardState();
}

class _RespuestaCardState
    extends State<_RespuestaCard> {
  bool abierta = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                abierta = !abierta;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pregunta,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    abierta
                        ? Icons
                            .keyboard_arrow_up_rounded
                        : Icons
                            .keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),

          if (abierta)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                18,
              ),
              child: Text(
                widget.respuesta.isEmpty
                    ? 'Sin respuesta'
                    : widget.respuesta,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      height: 1.45,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
