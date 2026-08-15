import 'package:flutter/material.dart';

import '../../domain/entities/grupo.dart';
import 'grupo_imagen.dart';

class GrupoCard extends StatelessWidget {
  const GrupoCard({
    super.key,
    required this.grupo,
    required this.onAbrir,
    required this.onCambiarMembresia,
    this.actualizando = false,
    this.accentColor = const Color(0xFF27A56D),
    this.icon = Icons.groups_rounded,
  });

  final Grupo grupo;
  final VoidCallback onAbrir;
  final VoidCallback onCambiarMembresia;
  final bool actualizando;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onAbrir,
        child: Column(
          children: [
            SizedBox(
              height: 84,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: portadaGrupo(grupo)),
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: .12),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: -24,
                    child: CircleAvatar(
                      radius: 29,
                      backgroundColor: colors.surface,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: imagenPerfilGrupo(grupo),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 31, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grupo.nombre,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.group_rounded,
                              size: 17,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${grupo.cantidadMiembros} miembros',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          grupo.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (actualizando)
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (grupo.solicitudPendiente)
                    OutlinedButton.icon(
                      onPressed: onCambiarMembresia,
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: const Text('Pendiente'),
                    )
                  else if (grupo.esMiembro)
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Ya eres miembro'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: onCambiarMembresia,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Unirme'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
