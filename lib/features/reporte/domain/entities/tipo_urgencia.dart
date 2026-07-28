enum TipoUrgencia {
  baja(1, 'Baja'),
  media(2, 'Media'),
  alta(3, 'Alta'),
  critica(4, 'Crítica');

  final int id;
  final String label;

  const TipoUrgencia(this.id, this.label);

  static String fromId(dynamic id) {
    int? idInt;
    if (id is int) {
      idInt = id;
    } else if (id is String) {
      idInt = int.tryParse(id);
    }

    if (idInt == null) return 'Desconocida';

    for (var urgencia in TipoUrgencia.values) {
      if (urgencia.id == idInt) {
        return urgencia.label;
      }
    }
    return 'Desconocida';
  }
}