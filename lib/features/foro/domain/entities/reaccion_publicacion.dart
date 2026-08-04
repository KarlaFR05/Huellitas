enum TipoReaccion { meGusta }

class ReaccionPublicacion {
  final int publicacionId;
  final int usuarioId;
  final TipoReaccion tipo;
  final DateTime fechaCreacion;

  const ReaccionPublicacion({
    required this.publicacionId,
    required this.usuarioId,
    this.tipo = TipoReaccion.meGusta,
    required this.fechaCreacion,
  });
}
