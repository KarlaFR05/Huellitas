import 'package:flutter/material.dart';
import 'reporte_marker.dart';

/// Botón flotante que abre el filtro del mapa. Muestra un badge
/// con la cantidad de filtros activos.
class FiltroReportesButton extends StatelessWidget {
  final int cantidadActiva;
  final VoidCallback onTap;

  const FiltroReportesButton({
    super.key,
    required this.cantidadActiva,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.tune_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              if (cantidadActiva > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cantidadActiva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet con chips seleccionables para filtrar por tipo de
/// animal y nivel de urgencia. Selección vacía = mostrar todos.
class FiltroReportesSheet extends StatefulWidget {
  final Set<ReportAnimal> animalesSeleccionados;
  final Set<ReportUrgency> urgenciasSeleccionadas;

  const FiltroReportesSheet({
    super.key,
    required this.animalesSeleccionados,
    required this.urgenciasSeleccionadas,
  });

  @override
  State<FiltroReportesSheet> createState() => _FiltroReportesSheetState();
}

class _FiltroReportesSheetState extends State<FiltroReportesSheet> {
  late Set<ReportAnimal> _animales;
  late Set<ReportUrgency> _urgencias;

  @override
  void initState() {
    super.initState();
    _animales = {...widget.animalesSeleccionados};
    _urgencias = {...widget.urgenciasSeleccionadas};
  }

  void _toggleAnimal(ReportAnimal a) {
    setState(() {
      _animales.contains(a) ? _animales.remove(a) : _animales.add(a);
    });
  }

  void _toggleUrgencia(ReportUrgency u) {
    setState(() {
      _urgencias.contains(u) ? _urgencias.remove(u) : _urgencias.add(u);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hayFiltrosActivos = _animales.isNotEmpty || _urgencias.isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrar reportes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: hayFiltrosActivos
                      ? () => setState(() {
                          _animales.clear();
                          _urgencias.clear();
                        })
                      : null,
                  child: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Elige una o más opciones. Sin selección se muestran todos.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _SeccionTitulo(texto: 'ANIMAL'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ReportAnimal.values.map((a) {
                final sel = _animales.contains(a);
                return FilterChip(
                  selected: sel,
                  onSelected: (_) => _toggleAnimal(a),
                  showCheckmark: false,
                  avatar: Text(
                    a.shortLabel,
                    style: const TextStyle(fontSize: 14),
                  ),
                  label: Text(a.label),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            _SeccionTitulo(texto: 'NIVEL DE URGENCIA'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ReportUrgency.values.map((u) {
                final sel = _urgencias.contains(u);
                return FilterChip(
                  selected: sel,
                  onSelected: (_) => _toggleUrgencia(u),
                  showCheckmark: false,
                  avatar: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: u.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  label: Text(u.label),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  selectedColor: u.color,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  ResultadoFiltroReportes(_animales, _urgencias),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aplicar filtros',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Resultado que devuelve el bottom sheet de filtros al cerrarse.
class ResultadoFiltroReportes {
  final Set<ReportAnimal> animales;
  final Set<ReportUrgency> urgencias;

  const ResultadoFiltroReportes(this.animales, this.urgencias);
}
