import '../../domain/entities/usuario_publico.dart';

class UsuarioPublicoModel extends UsuarioPublico {
  const UsuarioPublicoModel({
    required super.usuarioIdPk,
    required super.nombre,
    required super.apellidos,
    required super.nombreUsuario,
    super.fotoPerfil,
    required super.verificado,
  });

  factory UsuarioPublicoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioPublicoModel(
      usuarioIdPk: json['usuario_id_pk'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      fotoPerfil: json['foto_perfil'],
      verificado: json['verificado'] ?? false,
    );
  }
}
