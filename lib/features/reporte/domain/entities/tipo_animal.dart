enum TipoAnimal {
  perro(1, 'Perro'),
  gato(2, 'Gato');

  final int id;
  final String label;

  const TipoAnimal(this.id, this.label);

  static String fromId(dynamic id) {
    int? idInt;
    if (id is int) {
      idInt = id;
    } else if (id is String) {
      idInt = int.tryParse(id);
    }

    if (idInt == null) return 'Desconocido';

    for (var animal in TipoAnimal.values) {
      if (animal.id == idInt) {
        return animal.label;
      }
    }
    return 'Desconocido';
  }
}