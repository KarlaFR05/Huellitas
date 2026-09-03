import 'package:shared_preferences/shared_preferences.dart';

class OrganizacionesSeguidasStorage {
  static const _prefijoClave = 'organizaciones_seguidas_usuario_';

  Future<Set<int>> obtener(int usuarioId) async {
    if (usuarioId <= 0) return <int>{};

    final preferencias = await SharedPreferences.getInstance();
    final valores = preferencias.getStringList('$_prefijoClave$usuarioId');
    return (valores ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> actualizar({
    required int usuarioId,
    required int organizacionId,
    required bool siguiendo,
  }) async {
    if (usuarioId <= 0) return;

    final preferencias = await SharedPreferences.getInstance();
    final organizaciones = await obtener(usuarioId);

    if (siguiendo) {
      organizaciones.add(organizacionId);
    } else {
      organizaciones.remove(organizacionId);
    }

    final valores = organizaciones.map((id) => id.toString()).toList()..sort();
    await preferencias.setStringList('$_prefijoClave$usuarioId', valores);
  }
}
