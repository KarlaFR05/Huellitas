import 'package:flutter/material.dart';
import '../../../../core/widgets/avatar_helper.dart';

import '../adopciones_postulaciones_store.dart';
import '../../domain/entities/adopcion.dart';
import 'adopcion_respuestas_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/adopciones_repository.dart';

class AdopcionesPostulacionesScreen extends StatefulWidget {
  const AdopcionesPostulacionesScreen({
    super.key,
    required this.adopcion,
  });

  final Adopcion adopcion;

  @override
  State<AdopcionesPostulacionesScreen> createState() =>
      _AdopcionesPostulacionesScreenState();
}

class _AdopcionesPostulacionesScreenState
    extends State<AdopcionesPostulacionesScreen> {
  late Future<List<PostulacionAdopcion>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<List<PostulacionAdopcion>> _cargar() async {
    final datos = await context
        .read<AdopcionesRepository>()
        .calcularRanking(widget.adopcion.id);

    return datos
        .map((json) => PostulacionAdopcion.fromJson(json))
        .toList();
  }

  bool _estaCompletada(List<PostulacionAdopcion> postulaciones) {
    return widget.adopcion.estaCompletada ||
        postulaciones.any((postulacion) => postulacion.fueAceptada);
  }

  String? _contactoDe(PostulacionAdopcion postulacion) {
    for (final pregunta in widget.adopcion.preguntas) {
      if (!pregunta.esMedioContacto || pregunta.id == null) continue;
      final respuesta = postulacion.respuestas[pregunta.id.toString()]?.trim();
      if (respuesta != null && respuesta.isNotEmpty) return respuesta;
    }
    final contacto =
        postulacion.contacto?.trim() ??
        widget.adopcion.contactoAdoptante?.trim();
    return contacto?.isNotEmpty == true ? contacto : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitudes de adopción',
        ),
      ),
      body: FutureBuilder<List<PostulacionAdopcion>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar las solicitudes: ${snapshot.error}',
              ),
            );
          }

          final postulaciones =
              snapshot.data ?? [];

          if (postulaciones.isEmpty) {
            return const _SinPostulaciones();
          }

          final adopcionCompletada = _estaCompletada(postulaciones);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32,
            ),
            children: [
              _EncabezadoAdopcion(
                adopcion: widget.adopcion,
                cantidad: postulaciones.length,
              ),

              const SizedBox(height: 22),

              if (adopcionCompletada) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: .35),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Adopción completada. Ya no se puede aceptar a otra persona.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              for (final postulacion in postulaciones)
                _PostulacionCard(
                  postulacion: postulacion,
                  adopcionCompletada: adopcionCompletada,
                  contactoPostulante: _contactoDe(postulacion),
                  onVerRespuestas: () async {
                    final aprobada =
                        await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdopcionRespuestasScreen(
                          adopcion:
                              widget.adopcion,
                          postulacion:
                              postulacion,
                          adopcionCompletada:
                              adopcionCompletada,
                        ),
                      ),
                    );

                    if (aprobada == true &&
                        mounted) {
                      setState(() {
                        _futuro = _cargar();
                      });
                    }
                  },
                ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _EncabezadoAdopcion
    extends StatelessWidget {
  const _EncabezadoAdopcion({
    required this.adopcion,
    required this.cantidad,
  });

  final Adopcion adopcion;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color:
                    colors.primaryContainer,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.pets_rounded,
                color: colors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    adopcion.nombre.isEmpty
                        ? 'Mascota en adopción'
                        : adopcion.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${adopcion.especie} · '
                    '${adopcion.edad} · '
                    '${adopcion.ciudad}',
                    style: TextStyle(
                      color:
                          colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          'Solicitudes de adopción',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),

        const SizedBox(height: 4),

        Text(
          'Las solicitudes se muestran según su nivel '
          'de aptitud para adoptar.',
          style: TextStyle(
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '$cantidad '
          '${cantidad == 1 ? 'postulación' : 'postulaciones'}',
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PostulacionCard
    extends StatelessWidget {
  const _PostulacionCard({
    required this.postulacion,
    required this.onVerRespuestas,
    required this.adopcionCompletada,
    required this.contactoPostulante,
  });

  final PostulacionAdopcion postulacion;
  final VoidCallback onVerRespuestas;
  final bool adopcionCompletada;
  final String? contactoPostulante;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final porcentaje =
        postulacion.porcentajeAptitud
            .clamp(0, 100);

    final estadoVisible = postulacion.fueAceptada
        ? 'Seleccionada'
        : adopcionCompletada
        ? 'No seleccionada'
        : postulacion.estado;

    final estadoColor =
        _colorEstado(
      context,
      estadoVisible,
    );

    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: .6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              14,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      colors.primaryContainer,
                  backgroundImage:
                      avatarProvider(
                    postulacion.fotoPerfil,
                  ),
                  child: postulacion
                              .fotoPerfil
                              ?.isNotEmpty ==
                          true
                      ? null
                      : Text(
                          postulacion.nombre
                                  .isNotEmpty
                              ? postulacion
                                  .nombre[0]
                                  .toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                colors.primary,
                            fontWeight:
                                FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        postulacion.nombre,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: estadoColor
                              .withValues(
                            alpha: .12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),
                        child: Text(
                          estadoVisible,
                          style: TextStyle(
                            color:
                                estadoColor,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            postulacion
                                    .entrevistaCompletada
                                ? Icons
                                    .check_circle_rounded
                                : Icons
                                    .schedule_rounded,
                            size: 15,
                            color: postulacion
                                    .entrevistaCompletada
                                ? Colors.green
                                : colors
                                    .onSurfaceVariant,
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Flexible(
                            child: Text(
                              '${postulacion.fechaRegistro == null ? 'Miembro desde —' : 'Miembro desde ${postulacion.fechaRegistro!.year}'}'
                              '${postulacion.ubicacion == null ? '' : ' · ${postulacion.ubicacion}'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors
                                    .onSurfaceVariant,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: Stack(
                        alignment:
                            Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value:
                                porcentaje / 100,
                            strokeWidth: 6,
                            backgroundColor:
                                colors
                                    .surfaceContainerHighest,
                          ),
                          Text(
                            '$porcentaje%',
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Nivel de aptitud',
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            colors
                                .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DatoPostulante(
                    icon: Icons
                        .workspace_premium_outlined,
                    titulo:
                        'Insignias de\nrescate',
                    valor:
                        '${postulacion.insigniasRescate}',
                  ),
                ),
                Expanded(
                  child: _DatoPostulante(
                    icon: Icons.report_outlined,
                    titulo:
                        'Insignias de\nreporte',
                    valor:
                        '${postulacion.insigniasReporte}',
                  ),
                ),
                Expanded(
                  child: _DatoPostulante(
                    icon: Icons
                        .volunteer_activism_rounded,
                    titulo:
                        'Insignias de\ndonación',
                    valor:
                        '${postulacion.insigniasDonacion}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Text(
                      'Nivel de aptitud',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors
                            .onSurfaceVariant,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    Text(
                      _textoAptitud(
                        porcentaje,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _colorAptitud(
                          porcentaje,
                        ),
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child:
                      LinearProgressIndicator(
                    value:
                        porcentaje / 100,
                    minHeight: 8,
                    backgroundColor: colors
                        .surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            padding:
                const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: colors
                  .surfaceContainerHighest
                  .withValues(alpha: .55),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 18,
                  color: colors.primary,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    'La solicitud fue completada por el postulante.',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (postulacion.fueAceptada &&
              contactoPostulante != null &&
              contactoPostulante!.isNotEmpty)
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                14,
              ),
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors
                    .primaryContainer
                    .withValues(alpha: .45),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.contact_phone_rounded,
                    color: colors.primary,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Contacto de ${postulacion.nombre}: $contactoPostulante',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed:
                    onVerRespuestas,
                child: const FittedBox(
                  child: Text(
                    'Conocer respuestas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstado(
    BuildContext context,
    String estado,
  ) {
    switch (estado.toLowerCase()) {
      case 'seleccionada':
      case 'muy apta':
        return Colors.green;

      case 'no seleccionada':
        return Theme.of(context).colorScheme.error;

      case 'apta':
        return Colors.orange;

      case 'en evaluación':
        return Colors.orange;

      default:
        return Theme.of(context)
            .colorScheme
            .onSurfaceVariant;
    }
  }

  String _textoAptitud(int porcentaje) {
    if (porcentaje >= 85) {
      return 'Muy apta';
    }

    if (porcentaje >= 70) {
      return 'Apta';
    }

    if (porcentaje >= 50) {
      return 'En evaluación';
    }

    return 'Baja';
  }

  Color _colorAptitud(int porcentaje) {
    if (porcentaje >= 85) {
      return Colors.green;
    }

    if (porcentaje >= 70) {
      return Colors.orange;
    }

    return Colors.red;
  }
}

class _DatoPostulante
    extends StatelessWidget {
  const _DatoPostulante({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  final IconData icon;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: colors.primary,
        ),

        const SizedBox(height: 4),

        Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          valor,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SinPostulaciones
    extends StatelessWidget {
  const _SinPostulaciones();

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: colors.primary,
            ),

            const SizedBox(height: 16),

            Text(
              'Aún no hay postulaciones',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Cuando alguien quiera adoptar esta '
              'mascota, su solicitud aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
