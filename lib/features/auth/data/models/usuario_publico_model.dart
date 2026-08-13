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
    final data = json['usuario'] is Map
        ? Map<String, dynamic>.from(json['usuario'] as Map)
        : json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return UsuarioPublicoModel(
      usuarioIdPk: _entero(data['usuario_id_pk'] ?? data['usuario_id'] ?? data['id']),
      nombre: (data['nombre'] ?? '').toString(),
      apellidos: (data['apellidos'] ?? '').toString(),
      nombreUsuario: (data['nombre_usuario'] ?? data['nombreUsuario'] ?? '').toString(),
      correo: (data['correo'] ?? '').toString(),
      numTelefono: (data['num_telefono'] ?? data['telefono'] ?? '').toString(),
      fotoPerfil: data['foto_perfil']?.toString(),
      verificado: data['verificado'] == true || data['verificado'] == 1,
    );
  }

  static int _entero(Object? valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

}
