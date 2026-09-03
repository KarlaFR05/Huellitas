import 'package:flutter/material.dart';

import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../domain/entities/organizacion_foro.dart';

class OrganizacionCard extends StatefulWidget {
  final OrganizacionForo organizacion;
  final VoidCallback onTap;
  final Future<void> Function() onToggleSeguir;

  const OrganizacionCard({
    super.key,
    required this.organizacion,
    required this.onTap,
    required this.onToggleSeguir,
  });

  @override
  State<OrganizacionCard> createState() => _OrganizacionCardState();
}

class _OrganizacionCardState extends State<OrganizacionCard> {
  bool _actualizandoSeguimiento = false;

  Future<void> _toggleSeguir() async {
    if (_actualizandoSeguimiento) return;

    setState(() => _actualizandoSeguimiento = true);
    try {
      await widget.onToggleSeguir();
    } finally {
      if (mounted) {
        setState(() => _actualizandoSeguimiento = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 165,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _actualizandoSeguimiento ? null : widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: widget.organizacion.logoUrl.isNotEmpty
                      ? NetworkImage(widget.organizacion.logoUrl)
                      : null,
                  child: widget.organizacion.logoUrl.isEmpty
                      ? Icon(Icons.pets_rounded, color: colors.primary)
                      : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.organizacion.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const OrganizacionVerificadaBadge(size: 15),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.organizacion.cantidadSeguidores} seguidores',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: widget.organizacion.esSeguidor
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _actualizandoSeguimiento
                              ? null
                              : _toggleSeguir,
                          child: _actualizandoSeguimiento
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Siguiendo',
                                  style: TextStyle(fontSize: 12),
                                ),
                        )
                      : FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _actualizandoSeguimiento
                              ? null
                              : _toggleSeguir,
                          child: _actualizandoSeguimiento
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Seguir',
                                  style: TextStyle(fontSize: 12),
                                ),
                        ),
                ),
                /*const SizedBox(height: 4),
                Text(
                  'Ver perfil ›',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
