import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'reporte_marker.dart';

class MapWidget extends StatefulWidget {
  final List<ReportMapMarker> markers;
  final LatLng? userLocation;
  final MapController? mapController;

  const MapWidget({
    super.key,
    required this.markers,
    this.userLocation,
    this.mapController,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.mapController ?? MapController();
  }
  //mostrar imagen en pantalla completa
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.white, size: 48),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            22, // qué tan cerca puede acercarse (número más alto = más cercano)
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.huellitas.app',
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
                alignment: Alignment
                    .topCenter, 
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusDot(color: report.urgency.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        report.tipoReporte,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: report.urgency.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          report.animal.shortLabel,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (report.fotoUrl != null) ...[
                  // ✅ IMAGEN MODIFICADA: Ahora es clicable para ampliar
                  GestureDetector(
                    onTap: () => _showFullImage(context, report.fotoUrl!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.network(
                            report.fotoUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                          // Badge "Ver" en la esquina
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ver',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _InfoRow(label: 'Tipo', value: report.tipoReporte),
                _InfoRow(label: 'Urgencia', value: report.urgency.label),
                _InfoRow(label: 'Animal', value: report.animal.label),
                _InfoRow(label: 'Tamaño', value: report.tamano),
                _InfoRow(label: 'Ubicación', value: report.ubicacion),
                _InfoRow(
                  label: 'Radio',
                  value: '${report.radiusMeters.round()} m',
                ),
                const SizedBox(height: 12),
                Text(
                  report.description,
                  style: const TextStyle(fontSize: 15, height: 1.35),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ubicación aproximada',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (report.reporteId == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Este reporte no tiene ID válido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    context.push('/reporte-estado/${report.reporteId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF57C29A),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver estado del reporte',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
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