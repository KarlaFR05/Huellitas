import 'package:flutter/material.dart';

import 'reporte_marker.dart';

class ReporteCircle {
  static Color getColor(ReportUrgency urgency) {
    return urgency.color.withValues(alpha: .20);
  }
}
