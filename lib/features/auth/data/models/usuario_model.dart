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
    super.calle,
    super.colonia,
    super.cp,
    super.ciudad,
    super.estado,
    super.fotoPerfil,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      usuarioIdPk: json['usuario_id_pk'] ?? 0,
      correo: json['correo'] ?? '',
      nombre: json['nombre'] ?? 'Usuario',
      apellidos: json['apellidos'] ?? '',
      numTelefono: json['num_telefono'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.tryParse(json['fecha_nacimiento']) ?? DateTime.now()
          : DateTime.now(),
      verificado: json['verificado'] ?? false,
      fechaRegistroUsuario: json['fecha_registro_usuario'] != null
          ? DateTime.tryParse(json['fecha_registro_usuario']) ?? DateTime.now()
          : DateTime.now(),
      rolUsuario: json['rol_usuario'] ?? 'usuario',
      calle: json['calle'],
      colonia: json['colonia'],
      cp: json['cp'],
      ciudad: json['ciudad'],
      estado: json['estado'],
      fotoPerfil: json['foto_perfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id_pk': usuarioIdPk,
      'correo': correo,
      'nombre': nombre,
      'apellidos': apellidos,
      'num_telefono': numTelefono,
      'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'verificado': verificado,
      'fecha_registro_usuario': fechaRegistroUsuario.toIso8601String(),
      'rol_usuario': rolUsuario,
      'calle': calle,
      'colonia': colonia,
      'cp': cp,
      'ciudad': ciudad,
      'estado': estado,
      'foto_perfil': fotoPerfil,
    };
  }
}
