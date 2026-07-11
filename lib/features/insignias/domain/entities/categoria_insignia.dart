import 'package:flutter/material.dart';

enum CategoriaInsignia {
  rescate,
  donacion,
  reporte;

  String get label {
    switch (this) {
      case CategoriaInsignia.rescate:
        return 'Rescates';
      case CategoriaInsignia.donacion:
        return 'Donaciones';
      case CategoriaInsignia.reporte:
        return 'Reportes';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoriaInsignia.rescate:
        return Icons.favorite_outline;
      case CategoriaInsignia.donacion:
        return Icons.attach_money;
      case CategoriaInsignia.reporte:
        return Icons.report_outlined;
    }
  }
}