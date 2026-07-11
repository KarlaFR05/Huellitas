enum TipoReporte {
  mascotaPerdida(1, 'Mascota perdida'),
  mascotaEncontrada(2, 'Mascota encontrada'),
  animalAbandono(3, 'Animal en abandono/riesgo'),
  maltratoAnimal(4, 'Maltrato animal');

  final int id;
  final String label;

  const TipoReporte(this.id, this.label);

  static String fromId(dynamic id) {
    int? idInt;
    if (id is int) {
      idInt = id;
    } else if (id is String) {
      idInt = int.tryParse(id);
    }

    if (idInt == null) return 'Desconocido';

    for (var reporte in TipoReporte.values) {
      if (reporte.id == idInt) {
        return reporte.label;
      }
    }
    return 'Desconocido';
  }
}