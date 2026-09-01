import 'package:flutter/material.dart';
import '../../../../core/widgets/avatar_helper.dart';

import '../adopciones_postulaciones_store.dart';
import '../../domain/entities/adopcion.dart';
import 'adopcion_respuestas_screen.dart';

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
  final Set<PostulacionAdopcion> _seleccionadas = {};

  Future<void> _aceptarSeleccionadas() async {
    if (_seleccionadas.isEmpty) return;
    final nombres = _seleccionadas.map((p) => p.nombre).join(', ');
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar postulantes'),
        content: Text(
          '¿Deseas aceptar a $nombres? Las demás postulaciones se eliminarán y las personas aceptadas recibirán una notificación.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, aceptar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final contacto = await _pedirContactoResponsable();
    if (contacto == null || !mounted) return;
    PostulacionesAdopcionStore.cerrar(widget.adopcion.id, _seleccionadas, contacto);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se aceptó ${_seleccionadas.length == 1 ? 'la postulación de ${_seleccionadas.first.nombre}' : 'a ${_seleccionadas.length} postulantes'}.')),
    );
    setState(() => _seleccionadas.clear());
  }

  Future<String?> _pedirContactoResponsable() async {
    final controller = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comparte tus datos de contacto'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Teléfono o medio de contacto',
            hintText: 'Ej. 55 1234 5678',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final contacto = controller.text.trim();
              if (contacto.isNotEmpty) Navigator.pop(context, contacto);
            },
            child: const Text('Compartir y finalizar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final postulaciones =
        PostulacionesAdopcionStore.deAdopcion(
      widget.adopcion.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de adopción'),
      ),
      body: postulaciones.isEmpty
          ? _SinPostulaciones()
          : ListView(
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

                for (final postulacion in postulaciones)
                  _PostulacionCard(
                    postulacion: postulacion,
                    seleccionada: _seleccionadas.contains(postulacion),
                    seleccionable:
                        _seleccionadas.isEmpty ||
                        _seleccionadas.contains(postulacion),
                    onSeleccionar: () => setState(() {
                      if (_seleccionadas.contains(postulacion)) {
                        _seleccionadas.remove(postulacion);
                      } else {
                        _seleccionadas.clear();
                        _seleccionadas.add(postulacion);
                      }
                    }),
                    onVerRespuestas: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdopcionRespuestasScreen(
                            adopcion: widget.adopcion,
                            postulacion: postulacion,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 76),
              ],
            ),
      bottomNavigationBar: postulaciones.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: _seleccionadas.isEmpty ? null : _aceptarSeleccionadas,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Cerrar adopción con el postulante'),
              ),
            ),
    );
  }
}
class _EncabezadoAdopcion extends StatelessWidget {
  const _EncabezadoAdopcion({
    required this.adopcion,
    required this.cantidad,
  });

  final Adopcion adopcion;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
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
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${adopcion.especie} · '
                    '${adopcion.edad} · '
                    '${adopcion.ciudad}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
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
class _PostulacionCard extends StatelessWidget {
  const _PostulacionCard({
    required this.postulacion,
    required this.onVerRespuestas,
    required this.seleccionada,
    required this.seleccionable,
    required this.onSeleccionar,
  });

  final PostulacionAdopcion postulacion;
  final VoidCallback onVerRespuestas;
  final bool seleccionada;
  final bool seleccionable;
  final VoidCallback onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final porcentaje =
        postulacion.porcentajeAptitud.clamp(0, 100);

    final estadoColor = _colorEstado(
      context,
      postulacion.estado,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // =========================
          // INFORMACIÓN DEL POSTULANTE
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO / AVATAR
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: avatarProvider(postulacion.fotoPerfil),
                  child: postulacion.fotoPerfil?.isNotEmpty == true ? null : Text(
                    postulacion.nombre.isNotEmpty
                        ? postulacion.nombre[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // NOMBRE + ESTADO
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        postulacion.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: .12),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          postulacion.estado,
                          style: TextStyle(
                            color: estadoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            postulacion.entrevistaCompletada
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            size: 15,
                            color:
                                postulacion.entrevistaCompletada
                                    ? Colors.green
                                    : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${postulacion.fechaRegistro == null ? 'Miembro desde —' : 'Miembro desde ${postulacion.fechaRegistro!.year}'}'
                              '${postulacion.ubicacion == null ? '' : ' · ${postulacion.ubicacion}'}',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                Checkbox(value: seleccionada, onChanged: seleccionable ? (_) => onSeleccionar() : null),

                // PORCENTAJE
                Column(
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: porcentaje / 100,
                            strokeWidth: 6,
                            backgroundColor:
                                colors.surfaceContainerHighest,
                          ),
                          Text(
                            '$porcentaje%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
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
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // INFORMACIÓN ADICIONAL
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DatoPostulante(
                    icon: Icons.workspace_premium_outlined,
                    titulo: 'Insignias de\nrescate',
                    valor: '${postulacion.insigniasRescate}',
                  ),
                ),

                Expanded(
                  child: _DatoPostulante(
                    icon: Icons.report_outlined,
                    titulo: 'Insignias de\nreporte',
                    valor: '${postulacion.insigniasReporte}',
                  ),
                ),

                Expanded(
                  child: _DatoPostulante(
                    icon: Icons.volunteer_activism_rounded,
                    titulo: 'Insignias de\ndonación',
                    valor: '${postulacion.insigniasDonacion}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // =========================
          // BARRA DE APTITUD
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nivel de aptitud',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _textoAptitud(porcentaje),
                      style: TextStyle(
                        fontSize: 12,
                        color: _colorAptitud(
                          porcentaje,
                        ),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    minHeight: 8,
                    backgroundColor:
                        colors.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // =========================
          // COMENTARIO / OBSERVACIÓN
          // =========================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest
                  .withValues(alpha: .55),
              borderRadius: BorderRadius.circular(12),
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
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (postulacion.fueAceptada &&
              postulacion.contacto != null &&
              postulacion.contacto!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.contact_phone_rounded, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contacto de ${postulacion.nombre}: ${postulacion.contacto}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // =========================
          // BOTÓN VER RESPUESTAS
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: onVerRespuestas,
                child: const FittedBox(
                  child: Text('Conocer respuestas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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
      case 'muy apta':
        return Colors.green;

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
class _DatoPostulante extends StatelessWidget {
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
    final colors = Theme.of(context).colorScheme;

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
class _SinPostulaciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando alguien quiera adoptar esta '
              'mascota, su solicitud aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
