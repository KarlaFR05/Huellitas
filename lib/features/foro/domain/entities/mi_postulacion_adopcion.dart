class MiPostulacionAdopcion {
  const MiPostulacionAdopcion({
    required this.yaPostulado,
    this.estado,
    this.contactoResponsable,
  });

  const MiPostulacionAdopcion.noPostulado()
    : yaPostulado = false,
      estado = null,
      contactoResponsable = null;

  final bool yaPostulado;
  final String? estado;
  final String? contactoResponsable;

  bool get fueAceptada {
    final valor = estado?.trim().toLowerCase();
    return const {
      'aprobada',
      'aprobado',
      'aceptada',
      'aceptado',
      'seleccionada',
      'seleccionado',
    }.contains(valor);
  }

  bool get fueRechazada {
    final valor = estado?.trim().toLowerCase();
    return const {
      'rechazada',
      'rechazado',
      'no_seleccionada',
      'no seleccionado',
    }.contains(valor);
  }
}
