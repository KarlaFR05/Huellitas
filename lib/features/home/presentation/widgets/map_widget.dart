import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import 'reporte_marker.dart';

class MapWidget extends StatefulWidget {
  final List<ReportMapMarker> markers;
  final LatLng? userLocation;
  final MapController? mapController;
  final int? reporteIdInicial;

  const MapWidget({
    super.key,
    required this.markers,
    this.userLocation,
    this.mapController,
    this.reporteIdInicial,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _controller;
  static const String _cartoApiKey = String.fromEnvironment('CARTO_API_KEY');

  @override
  void initState() {
    super.initState();
    _controller = widget.mapController ?? MapController();

    if (widget.reporteIdInicial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enfocarReporteInicial();
      });
    } else {}
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.reporteIdInicial != null &&
        widget.reporteIdInicial != oldWidget.reporteIdInicial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enfocarReporteInicial();
      });
    }
  }

  void _enfocarReporteInicial() {
    if (!mounted) {
      return;
    }

    ReportMapMarker? marcador;
    for (final m in widget.markers) {
      if (m.reporteId == widget.reporteIdInicial) {
        marcador = m;
        break;
      }
    }

    if (marcador == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos ubicar ese reporte en el mapa'),
        ),
      );
      return;
    }
    _controller.move(marcador.location, 17);
    _showReportInfo(context, marcador);
  }

  //mostrar imagen en pantalla completa
  void _showFullImage(BuildContext context, String imageUrl) {
    showFullScreenImage(
      context,
      image: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white, size: 48),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
      semanticLabel: 'Evidencia del reporte en el mapa',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final initialCenter =
        widget.userLocation ??
        (widget.markers.isNotEmpty
            ? widget.markers.first.location
            : LatLng(19.0414, -98.2063));

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 16,
        minZoom:
            5, // qué tan lejos puede alejarse (número más bajo = más alejado)
        maxZoom:
            20, // qué tan cerca puede acercarse (número más alto = más cercano)
      ),
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.matrix(
            isDarkMode
                ? const <double>[
                    -0.1084,
                    -0.3648,
                    -0.0368,
                    0,
                    164,
                    -0.1159,
                    -0.3871,
                    -0.0391,
                    0,
                    180,
                    -0.1217,
                    -0.4095,
                    -0.0413,
                    0,
                    210,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]
                : const <double>[
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ],
          ),
          child: TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.huellitas.app',
          ),
        ),
        CircleLayer(
          circles: widget.markers
              .where(
                (marker) =>
                    marker.tipoReporte != 'Maltrato animal' &&
                    marker.faseActualId != 3,
              )
              .map(
                (marker) => CircleMarker(
                  point: marker.location,
                  radius: marker.radiusMeters,
                  useRadiusInMeter: true,
                  color: marker.urgency.color.withValues(alpha: .18),
                  borderColor: marker.urgency.color.withValues(alpha: .45),
                  borderStrokeWidth: 2,
                ),
              )
              .toList(),
        ),
        MarkerLayer(
          markers: [
            ...widget.markers.map(
              (report) => Marker(
                point: report.location,
                width: 52,
                height: 62,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => _showReportInfo(context, report),
                  child: _ReportPin(report: report),
                ),
              ),
            ),
            if (widget.userLocation != null)
              Marker(
                point: widget.userLocation!,
                width: 24,
                height: 24,
                child: const _UserLocationDot(),
              ),
          ],
        ),
      ],
    );
  }

  void _showReportInfo(BuildContext context, ReportMapMarker report) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: report.fotoUrl != null
                            ? () =>
                                  _showFullImage(sheetContext, report.fotoUrl!)
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: report.fotoUrl != null
                              ? Image.network(
                                  report.fotoUrl!,
                                  width: 150,
                                  height: 190,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _FotoPlaceholder(
                                    color: report.urgency.color,
                                  ),
                                )
                              : _FotoPlaceholder(color: report.urgency.color),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _UrgencyBadge(
                              label: report.tipoReporte,
                              emoji: report.animal.shortLabel,
                              color: report.urgency.color,
                            ),
                            const SizedBox(height: 10),
                            _InfoRowCompact(
                              label: 'Urgencia',
                              value: report.urgency.label,
                            ),
                            _InfoRowCompact(
                              label: 'Animal',
                              value: report.animal.label,
                            ),
                            _InfoRowCompact(
                              label: 'Tamaño',
                              value: report.tamano,
                            ),
                            _InfoRowCompact(
                              label: 'Ubicación',
                              value: report.ubicacion,
                            ),
                            _InfoRowCompact(
                              label: 'Radio',
                              value: '${report.radiusMeters.round()} m',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (report.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      report.description,
                      style: const TextStyle(fontSize: 15, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (report.reporteId == null) {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('Este reporte no tiene ID válido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(sheetContext);
                      sheetContext.push('/reporte-estado/${report.reporteId}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        sheetContext,
                      ).colorScheme.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ver estado del reporte',
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportPin extends StatelessWidget {
  final ReportMapMarker report;

  const _ReportPin({required this.report});

  @override
  Widget build(BuildContext context) {
    return ReporteMarker(
      animal: report.animal,
      urgency: report.urgency,
      faseActualId: report.faseActualId,
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;

  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;

  const _UrgencyBadge({
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowCompact extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRowCompact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoPlaceholder extends StatelessWidget {
  final Color color;

  const _FotoPlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 190,
      color: color.withValues(alpha: 0.1),
      child: Icon(Icons.pets, color: color.withValues(alpha: 0.5), size: 36),
    );
  }
}
