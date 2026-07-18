import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'dart:ui' as ui;
import '../../../reporte/domain/entities/reporte.dart';

final List<ReportMapMarker> demoReportMarkers = [
  ReportMapMarker(
    tipoReporte: 'Animal en abandono/riesgo',
    description:
        'Perro mediano visto cerca del parque, parece desorientado y con una herida visible.',
    ubicacion: 'Zona centro',
    tamano: 'Mediano',
    location: LatLng(19.0414, -98.2063),
    radiusMeters: 180,
    animal: ReportAnimal.dog,
    urgency: ReportUrgency.alta,
  ),
  ReportMapMarker(
    tipoReporte: 'Mascota encontrada',
    description:
        'Gato pequeno encontrado bajo un auto. Esta resguardado temporalmente por vecinos.',
    ubicacion: 'Colonia cercana',
    tamano: 'Pequeno',
    location: LatLng(19.0470, -98.2028),
    radiusMeters: 160,
    animal: ReportAnimal.cat,
    urgency: ReportUrgency.media,
  ),
  ReportMapMarker(
    tipoReporte: 'Mascota perdida',
    description:
        'Perro grande con collar rojo. Ultima vez visto cerca del mercado.',
    ubicacion: 'Mercado principal',
    tamano: 'Grande',
    location: LatLng(19.0368, -98.2110),
    radiusMeters: 220,
    animal: ReportAnimal.dog,
    urgency: ReportUrgency.baja,
  ),
  ReportMapMarker(
    tipoReporte: 'Maltrato animal',
    description:
        'Reporte critico de gato en posible situacion de maltrato. Requiere atencion inmediata.',
    ubicacion: 'Zona residencial',
    tamano: 'Moderado',
    location: LatLng(19.0442, -98.2145),
    radiusMeters: 140,
    animal: ReportAnimal.cat,
    urgency: ReportUrgency.critica,
  ),
];

class ReportMapMarker {
  final int? reporteId;
  final String tipoReporte;
  final String description;
  final String ubicacion;
  final String tamano;
  final String? fotoUrl;
  final LatLng location;
  final double radiusMeters;
  final ReportAnimal animal;
  final ReportUrgency urgency;
  final int faseActualId;
  final DateTime? fechaActualizacion;

  const ReportMapMarker({
    this.reporteId,
    required this.tipoReporte,
    required this.description,
    required this.ubicacion,
    required this.tamano,
    this.fotoUrl,
    required this.location,
    required this.radiusMeters,
    required this.animal,
    required this.urgency,
    this.faseActualId = 1,
    this.fechaActualizacion,
  });

  factory ReportMapMarker.fromReporte(Reporte reporte) {
    return ReportMapMarker(
      reporteId: reporte.id,
      tipoReporte: _tipoReporteLabel(reporte.tipoReporteId),
      description: reporte.descripcion,
      ubicacion: reporte.ubicacion,
      tamano: reporte.tamano,
      fotoUrl: reporte.evidencia.isEmpty ? null : reporte.evidencia,
      location: LatLng(reporte.latitud, reporte.longitud),
      radiusMeters: 180,
      animal: ReportAnimal.fromId(reporte.tipoAnimalId),
      urgency: ReportUrgency.fromId(reporte.urgenciaId),
      faseActualId: reporte.faseActualId,
      fechaActualizacion: reporte.fechaActualizacion,
    );
  }

  static String _tipoReporteLabel(int id) {
    switch (id) {
      case 1:
        return 'Mascota perdida';
      case 2:
        return 'Mascota encontrada';
      case 3:
        return 'Animal en abandono/riesgo';
      case 4:
        return 'Maltrato animal';
      default:
        return 'Reporte';
    }
  }
}

enum ReportAnimal {
  dog,
  cat;

  String get label {
    switch (this) {
      case ReportAnimal.dog:
        return 'Perro';
      case ReportAnimal.cat:
        return 'Gato';
    }
  }

  String get shortLabel {
    switch (this) {
      case ReportAnimal.dog:
        return '🐶';
      case ReportAnimal.cat:
        return '🐱';
    }
  }

  static ReportAnimal fromId(int id) {
    return id == 1 ? ReportAnimal.dog : ReportAnimal.cat;
  }
}

enum ReportUrgency {
  baja,
  media,
  alta,
  critica;

  String get label {
    switch (this) {
      case ReportUrgency.baja:
        return 'Baja';
      case ReportUrgency.media:
        return 'Media';
      case ReportUrgency.alta:
        return 'Alta';
      case ReportUrgency.critica:
        return 'Critica';
    }
  }

  Color get color {
    switch (this) {
      case ReportUrgency.baja:
        return const Color(0xFFFBC02D);
      case ReportUrgency.media:
        return const Color(0xFFFF6D00);
      case ReportUrgency.alta:
        return const Color.fromARGB(255, 215, 38, 35);
      case ReportUrgency.critica:
        return const Color(0xFF8B0000);
    }
  }

  static ReportUrgency fromId(int id) {
    switch (id) {
      case 1:
        return ReportUrgency.baja;
      case 2:
        return ReportUrgency.media;
      case 3:
        return ReportUrgency.alta;
      case 4:
        return ReportUrgency.critica;
      default:
        return ReportUrgency.baja;
    }
  }
}

class ReporteMarker extends StatelessWidget {
  final ReportAnimal animal;
  final ReportUrgency urgency;
  final int faseActualId;

  const ReporteMarker({
    super.key,
    required this.animal,
    required this.urgency,
    this.faseActualId = 1,
  });

  Color get _colorEfectivo {
    if (faseActualId == 3) return const Color(0xFF2E7D32); // verde = concluido
    return urgency.color;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 58,
      child: CustomPaint(
        painter: _PinPainter(color: _colorEfectivo),
        child: Align(
          alignment: const Alignment(0, -0.55),
          child: Container(
            width: 26,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                animal.shortLabel,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;

  _PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;
    final center = Offset(w / 2, r);
    final tip = Offset(w / 2, h);

    final d = tip.dy - center.dy;
    late final ui.Path path;

    if (d > r) {
      // Ángulo exacto de las líneas tangentes desde la punta hasta el círculo
      final tangentAngle = math.acos(r / d);
      const down = math.pi / 2;
      final angleLeft = down + tangentAngle;
      final angleRight = down - tangentAngle;

      final t1 = Offset(
        center.dx + r * math.cos(angleLeft),
        center.dy + r * math.sin(angleLeft),
      );
      final t2 = Offset(
        center.dx + r * math.cos(angleRight),
        center.dy + r * math.sin(angleRight),
      );

      final circulo = ui.Path()
        ..addOval(Rect.fromCircle(center: center, radius: r));

      final triangulo = ui.Path()
        ..moveTo(t1.dx, t1.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(t2.dx, t2.dy)
        ..close();

      // Fusiona el círculo real con las líneas tangentes exactas:
      // el resultado es perfectamente suave en la unión, sin picos.
      path = ui.Path.combine(ui.PathOperation.union, circulo, triangulo);
    } else {
      path = ui.Path()..addOval(Rect.fromCircle(center: center, radius: r));
    }

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.3), 3, false);

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
