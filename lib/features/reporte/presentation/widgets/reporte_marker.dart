import 'package:flutter/material.dart';

import 'reporte_type.dart';

class ReporteMarker extends StatelessWidget {
  final ReporteType tipo;

  const ReporteMarker({
    super.key,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {

    IconData icon;
    Color color;

    switch (tipo) {
      case ReporteType.perdido:
        icon = Icons.search;
        color = Colors.red;
        break;

      case ReporteType.encontrado:
        icon = Icons.pets;
        color = Colors.green;
        break;

      case ReporteType.adopcion:
        icon = Icons.favorite;
        color = Colors.blue;
        break;

      case ReporteType.rescateUrgente:
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}