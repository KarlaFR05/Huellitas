class OrganizacionForo {
  final int id;
  final int usuarioId;
  final String nombre;
  final String descripcion;
  final String logoUrl;
  final String fotoPortada;
  final bool verificada;
  final int cantidadSeguidores;
  final bool esSeguidor;
  final String? tiposAnimales;
  final String? telefonoEmergencia;
  final String? correoInstitucional;
  final String? registroLegal;
  final DateTime? fechaFundacion;
  final double metaMensual;
  final double recaudadoMensual;

  const OrganizacionForo({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.descripcion = '',
    this.logoUrl = '',
    this.fotoPortada = '',
    this.verificada = true,
    this.cantidadSeguidores = 0,
    this.esSeguidor = false,
    this.tiposAnimales,
    this.telefonoEmergencia,
    this.correoInstitucional,
    this.registroLegal,
    this.fechaFundacion,
    this.metaMensual = 0,
    this.recaudadoMensual = 0,
  });
}