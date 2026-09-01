import 'package:flutter/material.dart';

import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../domain/entities/organizacion_foro.dart';

class OrganizacionCard extends StatefulWidget {
  final OrganizacionForo organizacion;
  final VoidCallback onTap;

  const OrganizacionCard({
    super.key,
    required this.organizacion,
    required this.onTap,
  });

  @override
  State<OrganizacionCard> createState() => _OrganizacionCardState();
}

class _OrganizacionCardState extends State<OrganizacionCard> {
  late bool _siguiendo;
  late int _seguidores;

  @override
  void initState() {
    super.initState();
    _siguiendo = widget.organizacion.esSeguidor;
    _seguidores = widget.organizacion.cantidadSeguidores;
  }

  void _toggleSeguir() {
    setState(() {
      _siguiendo = !_siguiendo;
      _seguidores += _siguiendo ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 165,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
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
                  '$_seguidores seguidores',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _siguiendo
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _toggleSeguir,
                          child: const Text(
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
                          onPressed: _toggleSeguir,
                          child: const Text(
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