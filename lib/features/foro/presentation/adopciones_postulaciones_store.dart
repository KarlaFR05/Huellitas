import '../../notificaciones/domain/entities/notificacion.dart';

class PostulacionAdopcion {
  const PostulacionAdopcion({
    required this.nombre,
    required this.respuestas,
    this.porcentajeAptitud = 0,
    this.estado = 'En evaluación',
    this.entrevistaCompletada = false,
    this.postulacionId,
    this.usuarioId,
    this.fechaRegistro,
    this.ubicacion,
    this.insigniasRescate = 0,
    this.insigniasReporte = 0,
    this.insigniasDonacion = 0,
    this.fotoPerfil,
    this.contacto,
    this.fueAceptada = false,
  });

  final String nombre;
  final Map<String, String> respuestas;

  /// Porcentaje de aptitud para adoptar (calculado por el backend con IA).
  final int porcentajeAptitud;

  /// "Muy apta" / "Apta" / "En evaluación" / "Baja"
  final String estado;

  /// Indica si ya completó la entrevista.
  final bool entrevistaCompletada;
  final int? postulacionId;
  final int? usuarioId;
  final DateTime? fechaRegistro;
  final String? ubicacion;
  final int insigniasRescate;
  final int insigniasReporte;
  final int insigniasDonacion;
  final String? fotoPerfil;
  final String? contacto;
  final bool fueAceptada;

  PostulacionAdopcion copyWith({
    String? contacto,
    bool? fueAceptada,
  }) => PostulacionAdopcion(
    nombre: nombre,
    respuestas: respuestas,
    porcentajeAptitud: porcentajeAptitud,
    estado: estado,
    entrevistaCompletada: entrevistaCompletada,
    postulacionId: postulacionId,
    usuarioId: usuarioId,
    fechaRegistro: fechaRegistro,
    ubicacion: ubicacion,
    insigniasRescate: insigniasRescate,
    insigniasReporte: insigniasReporte,
    insigniasDonacion: insigniasDonacion,
    fotoPerfil: fotoPerfil,
    contacto: contacto ?? this.contacto,
    fueAceptada: fueAceptada ?? this.fueAceptada,
  );

  factory PostulacionAdopcion.fromJson(Map<String, dynamic> json) {
    final porcentaje = ((json['score_final'] as num?)?.round() ?? 0)
        .clamp(0, 100)
        .toInt();

    String estadoTexto;
    if (porcentaje >= 85) {
      estadoTexto = 'Muy apta';
    } else if (porcentaje >= 70) {
      estadoTexto = 'Apta';
    } else if (porcentaje >= 50) {
      estadoTexto = 'En evaluación';
    } else {
      estadoTexto = 'Baja';
    }

    DateTime? fechaRegistroUsuario;
    final fechaRaw = json['fecha_registro_usuario'] as String?;
    if (fechaRaw != null) {
      fechaRegistroUsuario = DateTime.tryParse(fechaRaw);
    }

    final ubicacion = [
      json['ciudad'],
      json['estado_usuario'],
    ].whereType<String>().where((valor) => valor.trim().isNotEmpty).join(', ');

    final nombreUsuario = json['nombre_usuario'] as String?;

    return PostulacionAdopcion(
      nombre: (nombreUsuario != null && nombreUsuario.trim().isNotEmpty)
          ? nombreUsuario
          : 'Usuario #${json['usuario_id_fk']}',
      respuestas: {
        for (final r in (json['respuestas'] as List<dynamic>? ?? []))
          (r['pregunta_id']?.toString() ?? ''):
              (r['respuesta_texto'] as String? ?? ''),
      },
      porcentajeAptitud: porcentaje,
      estado: estadoTexto,
      entrevistaCompletada: true,
      usuarioId: json['usuario_id_fk'] as int?,
      fechaRegistro: fechaRegistroUsuario,
      ubicacion: ubicacion.isEmpty ? null : ubicacion,
      insigniasRescate: json['insignias_rescate'] as int? ?? 0,
      insigniasReporte: json['insignias_reporte'] as int? ?? 0,
      insigniasDonacion: json['insignias_donacion'] as int? ?? 0,
      fotoPerfil: json['foto_perfil'] as String?,
      postulacionId: json['postulacion_id'] as int?,
      contacto: json['contacto'] as String?,
      fueAceptada: json['fue_aceptada'] as bool? ?? false,
    );
  }
}

/// Almacenamiento temporal — ya no se usa para postulaciones (esas ahora
/// vienen del backend), se mantiene solo si algo más del código aún importa
/// esta clase.
class PostulacionesAdopcionStore {
  static final Map<int, List<PostulacionAdopcion>> _datos = {};
  static final Map<int, List<Notificacion>> _notificaciones = {};
  static var _siguienteNotificacionId = -1;

  static List<PostulacionAdopcion> deAdopcion(int id) =>
      List.unmodifiable(_datos[id] ?? const []);

  static void agregar(int id, PostulacionAdopcion postulacion) =>
      _datos.putIfAbsent(id, () => []).add(postulacion);

  static bool tienePostulacion(int id, String nombre) =>
      (_datos[id] ?? const []).any(
        (postulacion) => postulacion.nombre == nombre,
      );

  /// Compatibilidad para el flujo local de cierre de adopción.
  /// La aprobación definitiva se realiza mediante el backend.
  static void cerrar(
    int adopcionId,
    Iterable<PostulacionAdopcion> aceptadas,
    String contactoResponsable,
  ) {
    final seleccionadas = aceptadas.toSet();
    _datos[adopcionId] = (_datos[adopcionId] ?? const []).map((postulacion) {
      final fueAceptada = seleccionadas.contains(postulacion);
      final usuarioId = postulacion.usuarioId;
      if (usuarioId != null) {
        _notificaciones.putIfAbsent(usuarioId, () => []).add(
          Notificacion(
            id: _siguienteNotificacionId--,
            tipo: fueAceptada
                ? 'adopcion_aceptada'
                : 'adopcion_no_seleccionada',
            titulo: fueAceptada
                ? 'Postulación aceptada'
                : 'Postulación no seleccionada',
            mensaje: fueAceptada
                ? 'Tu solicitud fue aceptada. Revisa el contacto compartido.'
                : 'La adopción se cerró y tu solicitud no fue seleccionada.',
            data: {'adopcion_id': adopcionId},
            leida: false,
            creadaEn: DateTime.now(),
          ),
        );
      }
      return postulacion.copyWith(
        fueAceptada: fueAceptada,
        contacto: fueAceptada ? contactoResponsable : null,
      );
    }).toList();
  }

  static List<Notificacion> notificacionesDeUsuario(int usuarioId) =>
      List.unmodifiable(_notificaciones[usuarioId] ?? const []);
}
