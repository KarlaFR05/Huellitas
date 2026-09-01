import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/adopcion.dart';

class AdopcionCard extends StatelessWidget {
  const AdopcionCard({
    super.key,
    required this.adopcion,
    required this.onAbrir,
    this.esPropietario = false,
    this.postulacionPendiente = false,
    this.onAccion,
    this.cantidadSolicitudes = 0,
  });
  final Adopcion adopcion;
  final VoidCallback onAbrir;
  final bool esPropietario;
  final bool postulacionPendiente;
  final VoidCallback? onAccion;
  final int cantidadSolicitudes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final solicitudes = cantidadSolicitudes;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onAbrir,
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _imagen(),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _tag(
                            Icons.pets_rounded,
                            'Publicado',
                            colors.primary,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: _tag(
                            Icons.photo_outlined,
                            '1/1',
                            Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  adopcion.nombre.isEmpty
                                      ? 'Sin nombre'
                                      : adopcion.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                              Icon(
                                adopcion.sexo.toLowerCase() == 'hembra'
                                    ? Icons.female_rounded
                                    : Icons.male_rounded,
                                color: colors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            [
                              adopcion.edad,
                              adopcion.sexo,
                              adopcion.tamano,
                            ].where((x) => x.isNotEmpty).join(' · '),
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 17,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  adopcion.ciudad,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 9),
                            child: Divider(height: 1),
                          ),
                          Expanded(
                            child: Text(
                              adopcion.descripcion,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(height: 1.3),
                            ),
                          ),
                          Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            children: _vacunas
                                .map((vacuna) => _chip(context, vacuna))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              color: colors.surfaceContainerLow,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 19,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _footer(
                      'Publicado el',
                      _fecha(adopcion.fecha),
                      context,
                    ),
                  ),
                  Icon(
                    Icons.groups_2_outlined,
                    size: 19,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _footer('Solicitudes', '$solicitudes', context),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: FilledButton(
                      onPressed: postulacionPendiente
                          ? null
                          : (onAccion ?? onAbrir),
                      child: FittedBox(
                        child: Text(
                          esPropietario
                              ? 'Postulaciones'
                              : postulacionPendiente
                              ? 'Pendiente'
                              : 'Postularme',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagen() {
    final ruta = adopcion.imagenPath ?? adopcion.imagenUrl;
    if (ruta == null || ruta.isEmpty) return _placeholder();
    if (ruta.startsWith('http'))
      return Image.network(
        ruta,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    return Image.file(
      File(ruta),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Color(0xFFFFF0DB),
    child: Center(
      child: Icon(Icons.pets_rounded, size: 52, color: Color(0xFFFF9F2F)),
    ),
  );
  List<String> get _vacunas {
    final vacunas = adopcion.vacunas
        .split(RegExp(r'[,;\n]'))
        .map((vacuna) => vacuna.trim())
        .where((vacuna) => vacuna.isNotEmpty)
        .toList();
    return vacunas.isEmpty ? const ['Sin vacunas registradas'] : vacunas;
  }

  Widget _tag(IconData icon, String text, Color color) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _chip(BuildContext context, String text) => Container(
    constraints: const BoxConstraints(maxWidth: 140),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 10),
    ),
  );
  Widget _footer(String label, String value, BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ],
  );
  String _fecha(DateTime d) {
    const m = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
