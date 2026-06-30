import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'reporte_marker.dart';

class MapWidget extends StatelessWidget {
  final List<ReportMapMarker> markers;

  const MapWidget({super.key, required this.markers});

  @override
  Widget build(BuildContext context) {
    final initialCenter = markers.isNotEmpty
        ? markers.first.location
        : LatLng(19.0414, -98.2063);

    return FlutterMap(
      options: MapOptions(initialCenter: initialCenter, initialZoom: 14),

      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.huellitas.app',
        ),
        CircleLayer(
          circles: markers
              .map(
                (marker) => CircleMarker(
                  point: marker.location,
                  radius: marker.radiusMeters,
                  useRadiusInMeter: true,
                  color: marker.urgency.color.withOpacity(.18),
                  borderColor: marker.urgency.color.withOpacity(.45),
                  borderStrokeWidth: 2,
                ),
              )
              .toList(),
        ),
        MarkerLayer(
          markers: markers
              .map(
                (report) => Marker(
                  point: report.location,
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _showReportInfo(context, report),
                    child: _ReportPin(report: report),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showReportInfo(BuildContext context, ReportMapMarker report) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
                  Icon(
                    report.animal.icon,
                    color: report.urgency.color,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (report.fotoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    report.fotoUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _InfoRow(label: 'Tipo', value: report.tipoReporte),
              _InfoRow(label: 'Urgencia', value: report.urgency.label),
              _InfoRow(label: 'Animal', value: report.animal.label),
              _InfoRow(label: 'Tamano', value: report.tamano),
              _InfoRow(label: 'Ubicacion', value: report.ubicacion),
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
                'Ubicacion aproximada por seguridad.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportPin extends StatelessWidget {
  final ReportMapMarker report;

  const _ReportPin({required this.report});

  @override
  Widget build(BuildContext context) {
    return ReporteMarker(animal: report.animal, urgency: report.urgency);
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
            width: 64,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
