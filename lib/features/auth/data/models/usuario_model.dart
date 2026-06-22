import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  UsuarioModel({
    required super.usuarioIdPk,
    required super.correo,
    required super.nombre,
    required super.apellidos,
    required super.numTelefono,
    required super.fechaNacimiento,
    required super.verificado,
    required super.fechaRegistroUsuario,
    required super.rolUsuario,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      usuarioIdPk: json['usuario_id_pk'],
      correo: json['correo'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      numTelefono: json['num_telefono'],
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
      verificado: json['verificado'],
      fechaRegistroUsuario: DateTime.parse(json['fecha_registro_usuario']),
      rolUsuario: json['rol_usuario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'nombre': nombre,
      'apellidos': apellidos,
      'num_telefono': numTelefono,
      'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'verificado': verificado,
      'rol_usuario': rolUsuario,
    };
  }
}