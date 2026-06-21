import 'package:flutter/material.dart';

import 'reporte_type.dart';

class ReporteCircle {

  static Color getColor(
    ReporteType tipo,
  ) {

    switch (tipo) {
      case ReporteType.perdido:
        return Colors.red.withOpacity(.20);

      case ReporteType.encontrado:
        return Colors.green.withOpacity(.20);

      case ReporteType.adopcion:
        return Colors.blue.withOpacity(.20);

      case ReporteType.rescateUrgente:
        return Colors.orange.withOpacity(.20);
    }
  }
}