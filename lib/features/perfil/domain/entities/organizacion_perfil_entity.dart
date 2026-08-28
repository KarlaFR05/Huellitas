class OrganizacionPerfilEntity {
  final int id;
  final int usuarioId;
  final String nombre;
  final String? descripcion;
  final String? registroLegal;
  final String? categoria;
  final String? tiposAnimales;
  final String? telefonoEmergencia;
  final String? correoInstitucional;
  final String? fechaFundacion;
  final String? logoUrl;
  final String? fotoPortada;
  final String? cuentaBancaria;
  final String? banco;
  final String? titular;
  final bool verificada;
  final int cantidadSeguidores;
  final double metaMensual;
  final double recaudadoMensual;

  OrganizacionPerfilEntity({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.descripcion,
    this.registroLegal,
    this.categoria,
    this.tiposAnimales,
    this.telefonoEmergencia,
    this.correoInstitucional,
    this.fechaFundacion,
    this.logoUrl,
    this.fotoPortada,
    this.cuentaBancaria,
    this.banco,
    this.titular,
    this.verificada = true,
    this.cantidadSeguidores = 0,
    this.metaMensual = 0.0,
    this.recaudadoMensual = 0.0,
  });
}