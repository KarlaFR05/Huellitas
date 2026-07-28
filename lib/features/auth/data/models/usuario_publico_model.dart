import '../../domain/entities/usuario_publico.dart';

class UsuarioPublicoModel extends UsuarioPublico {
  const UsuarioPublicoModel({
    required super.usuarioIdPk,
    required super.nombre,
    required super.apellidos,
    required super.nombreUsuario,
    required super.correo,
    required super.numTelefono,
    super.fotoPerfil,
    required super.verificado,
  });

  factory UsuarioPublicoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioPublicoModel(
      usuarioIdPk: json['usuario_id_pk'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      correo: json['correo'] ?? '',
      numTelefono: json['num_telefono'] ?? '',
      fotoPerfil: json['foto_perfil'],
      verificado: json['verificado'] ?? false,
    );
  }
}
