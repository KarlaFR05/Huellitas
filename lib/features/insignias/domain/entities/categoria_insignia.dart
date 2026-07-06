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
}