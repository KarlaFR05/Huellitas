import 'package:dio/dio.dart';
import '../../domain/entities/notificacion.dart';

abstract class NotificacionRemoteDataSource {
  Future<List<Notificacion>> obtenerNotificaciones();
  Future<void> marcarComoLeida(int notificacionId);
  Future<void> marcarTodasComoLeidas();
  Future<void> guardarFcmToken(String token);
}

class NotificacionRemoteDataSourceImpl implements NotificacionRemoteDataSource {
  final Dio dio;
  NotificacionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Notificacion>> obtenerNotificaciones() async {
    final response = await dio.get('/notificaciones/usuario');
    final List<dynamic> data = response.data;
    return data.map((json) => _fromMap(json)).toList();
  }

  @override
  Future<void> marcarComoLeida(int notificacionId) async {
    await dio.patch('/notificaciones/$notificacionId/leida');
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    await dio.patch('/notificaciones/usuario/leer-todas');
  }

  @override
  Future<void> guardarFcmToken(String token) async {
    await dio.post('/usuarios/fcm-token', data: {'fcm_token': token});
  }

  Notificacion _fromMap(Map<String, dynamic> json) {
    final dataCruda = json['data'];
    final data = dataCruda is Map
        ? Map<String, dynamic>.from(dataCruda)
        : <String, dynamic>{};

    // Algunas notificaciones antiguas guardaron el identificador en la raíz.
    // Lo normalizamos para que sigan abriendo su contenido.
    for (final key in const [
      'reporte_id',
      'reporteId',
      'publicacion_id',
      'publicacionId',
      'grupo_id',
      'grupoId',
    ]) {
      if (data[key] == null && json[key] != null) data[key] = json[key];
    }

    return Notificacion(
      id: json['id'],
      tipo: json['tipo']?.toString().trim().toLowerCase() ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      data: data.isEmpty ? null : data,
      leida: json['leida'] ?? false,
      creadaEn:
          DateTime.tryParse(json['creada_en']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// Mock para pruebas
class NotificacionRemoteDataSourceMock implements NotificacionRemoteDataSource {
  final List<Notificacion> _mock = [
    // 1. Reporte tomado  /reporte-estado/1
    Notificacion(
      id: 1,
      tipo: 'reporte_tomado',
      titulo: '¡Tu reporte fue tomado!',
      mensaje: 'Un voluntario tomó el caso de tu reporte de maltrato.',
      data: {'reporte_id': 1},
      leida: false,
      creadaEn: DateTime.now().subtract(const Duration(minutes: 15)),
    ),

    // 2. Reporte cercano  /reporte-estado/2
    Notificacion(
      id: 2,
      tipo: 'reporte_cercano',
      titulo: 'Reporte cerca de ti',
      mensaje: 'Hay un reporte de animal a 300 metros de tu ubicación.',
      data: {'latitud': 19.04, 'longitud': -98.20, 'reporte_id': 2},
      leida: false,
      creadaEn: DateTime.now().subtract(const Duration(hours: 1)),
    ),

    // 3. Reacción /publicacion/1
    Notificacion(
      id: 3,
      tipo: 'reaccion',
      titulo: 'Nueva reacción',
      mensaje: 'A 3 personas les gustó tu publicación en el foro.',
      data: {'publicacion_id': 1, 'cantidad': 3},
      leida: false,
      creadaEn: DateTime.now().subtract(const Duration(hours: 2)),
    ),

    // 4. Comentario  /publicacion/1
    Notificacion(
      id: 4,
      tipo: 'comentario',
      titulo: 'Nuevo comentario',
      mensaje: 'María García comentó en tu publicación.',
      data: {'publicacion_id': 1, 'usuario_id': 5},
      leida: false,
      creadaEn: DateTime.now().subtract(const Duration(hours: 3)),
    ),

    // 5. Donación /historial
    Notificacion(
      id: 5,
      tipo: 'donacion',
      titulo: 'Gracias por tu donación',
      mensaje: 'Tu donación de \$150.00 fue procesada exitosamente.',
      data: {'monto': 150.0, 'organizacion': 'Refugio Patitas'},
      leida: true,
      creadaEn: DateTime.now().subtract(const Duration(days: 1)),
    ),

    // 6. Reporte exitoso  /home?reporteId=3
    Notificacion(
      id: 6,
      tipo: 'reporte_exitoso',
      titulo: '¡Reporte creado!',
      mensaje:
          'Tu reporte fue publicado exitosamente. Otros usuarios podrán verlo.',
      data: {'reporte_id': 3},
      leida: true,
      creadaEn: DateTime.now().subtract(const Duration(days: 2)),
    ),

    // 7. Nuevo miembro en grupo  /administrar-grupo/1
    Notificacion(
      id: 7,
      tipo: 'nuevo_miembro',
      titulo: 'Solicitud de ingreso',
      mensaje: 'Juan Pérez quiere unirse a tu grupo de rescate.',
      data: {'grupo_id': 1, 'usuario_id': 7, 'usuario_nombre': 'Juan Pérez'},
      leida: false,
      creadaEn: DateTime.now().subtract(const Duration(days: 3)),
    ),

    // 8. Aprobado en grupo  /administrar-grupo/1
    Notificacion(
      id: 8,
      tipo: 'aprobar_miembro',
      titulo: '¡Fuiste aceptado!',
      mensaje: 'Has sido aceptado en el grupo Rescatistas Puebla.',
      data: {'grupo_id': 1, 'grupo_nombre': 'Rescatistas Puebla'},
      leida: true,
      creadaEn: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  Future<List<Notificacion>> obtenerNotificaciones() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mock);
  }

  @override
  Future<void> marcarComoLeida(int notificacionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mock.indexWhere((n) => n.id == notificacionId);
    if (idx != -1) {
      final n = _mock[idx];
      _mock[idx] = Notificacion(
        id: n.id,
        tipo: n.tipo,
        titulo: n.titulo,
        mensaje: n.mensaje,
        data: n.data,
        leida: true,
        creadaEn: n.creadaEn,
      );
    }
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var i = 0; i < _mock.length; i++) {
      final n = _mock[i];
      _mock[i] = Notificacion(
        id: n.id,
        tipo: n.tipo,
        titulo: n.titulo,
        mensaje: n.mensaje,
        data: n.data,
        leida: true,
        creadaEn: n.creadaEn,
      );
    }
  }

  @override
  Future<void> guardarFcmToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
