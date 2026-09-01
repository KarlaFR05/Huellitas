import 'package:flutter/foundation.dart';
import '../../notificaciones/domain/entities/notificacion.dart';

class PostulacionAdopcion {
  const PostulacionAdopcion({
    required this.nombre,
    required this.respuestas,
    this.porcentajeAptitud = 0,
    this.estado = 'En evaluación',
    this.entrevistaCompletada = false,
    this.usuarioId,
    this.fechaRegistro,
    this.ubicacion,
    this.insigniasRescate = 0,
    this.insigniasReporte = 0,
    this.insigniasDonacion = 0,
    this.fotoPerfil,
    this.contacto,
    this.contactoResponsable,
    this.fueAceptada = false,
    this.fueRechazada = false,
  });

  final String nombre;
  final Map<String, String> respuestas;

  /// Porcentaje de aptitud para adoptar.
  final int porcentajeAptitud;

  /// Ejemplo:
  /// "Muy apta"
  /// "Apta"
  /// "En evaluación"
  final String estado;

  /// Indica si ya completó la entrevista.
  final bool entrevistaCompletada;
  final int? usuarioId;
  final DateTime? fechaRegistro;
  final String? ubicacion;
  final int insigniasRescate;
  final int insigniasReporte;
  final int insigniasDonacion;
  final String? fotoPerfil;
  /// Contacto que comparte el postulante al enviar su solicitud.
  final String? contacto;
  /// Contacto compartido por quien da la mascota en adopción al aceptar.
  final String? contactoResponsable;
  final bool fueAceptada;
  final bool fueRechazada;

  PostulacionAdopcion copyWith({
    String? contactoResponsable,
    bool? fueAceptada,
    bool? fueRechazada,
  }) => PostulacionAdopcion(
    nombre: nombre,
    respuestas: respuestas,
    porcentajeAptitud: porcentajeAptitud,
    estado: fueAceptada == true
        ? 'Aceptada'
        : fueRechazada == true ? 'No seleccionada' : estado,
    entrevistaCompletada: entrevistaCompletada,
    usuarioId: usuarioId,
    fechaRegistro: fechaRegistro,
    ubicacion: ubicacion,
    insigniasRescate: insigniasRescate,
    insigniasReporte: insigniasReporte,
    insigniasDonacion: insigniasDonacion,
    fotoPerfil: fotoPerfil,
    contacto: contacto,
    contactoResponsable: contactoResponsable ?? this.contactoResponsable,
    fueAceptada: fueAceptada ?? this.fueAceptada,
    fueRechazada: fueRechazada ?? this.fueRechazada,
  );
}

/// Almacenamiento temporal mientras se habilita el endpoint de postulaciones.
class PostulacionesAdopcionStore {
  static final Map<int, List<PostulacionAdopcion>> _datos = {};
  static final Set<int> _adopcionesCerradas = {};
  static final ValueNotifier<int> cambios = ValueNotifier(0);
  static final Map<int, List<Notificacion>> _notificaciones = {};
  static int _siguienteNotificacionId = -1;

  static List<PostulacionAdopcion> deAdopcion(int id) =>
      List.unmodifiable(_datos[id] ?? const []);

  static void agregar(
    int id,
    PostulacionAdopcion postulacion,
  ) {
    _datos.putIfAbsent(id, () => []).add(postulacion);
    cambios.notifyListeners();
  }

  static bool tienePostulacion(
    int id,
    String nombre,
  ) =>
      (_datos[id] ?? const []).any(
        (postulacion) => postulacion.nombre == nombre,
      );

  /// Conserva solamente a las personas aceptadas; las demás solicitudes se
  /// eliminan al cerrar el proceso de selección.
  static bool estaCerrada(int adopcionId) => _adopcionesCerradas.contains(adopcionId);

  static void cerrar(
    int adopcionId,
    Iterable<PostulacionAdopcion> aceptadas,
    String contactoResponsable,
  ) {
    final seleccionadas = aceptadas.toSet();
    _datos[adopcionId] = (_datos[adopcionId] ?? const [])
        .map((postulacion) {
          final fueAceptada = seleccionadas.contains(postulacion);
          if (postulacion.usuarioId != null) {
            _notificaciones.putIfAbsent(postulacion.usuarioId!, () => []).add(
              Notificacion(
                id: _siguienteNotificacionId--,
                tipo: fueAceptada ? 'adopcion_aceptada' : 'adopcion_no_seleccionada',
                titulo: fueAceptada ? 'Postulación aceptada' : 'Postulación no seleccionada',
                mensaje: fueAceptada
                    ? 'Tu solicitud de adopción fue aceptada. Revisa el contacto compartido.'
                    : 'La adopción se cerró y tu solicitud no fue seleccionada.',
                data: {'adopcion_id': adopcionId},
                leida: false,
                creadaEn: DateTime.now(),
              ),
            );
          }
          return postulacion.copyWith(
            fueAceptada: fueAceptada,
            fueRechazada: !fueAceptada,
            contactoResponsable: fueAceptada ? contactoResponsable : null,
          );
        })
        .toList();
    _adopcionesCerradas.add(adopcionId);
    cambios.notifyListeners();
  }

  static List<Notificacion> notificacionesDeUsuario(int usuarioId) =>
      List.unmodifiable(_notificaciones[usuarioId] ?? const []);

  static PostulacionAdopcion? postulacionDeUsuario(
    int adopcionId,
    int? usuarioId,
    String nombre,
  ) {
    for (final postulacion in _datos[adopcionId] ?? const []) {
      if ((usuarioId != null && postulacion.usuarioId == usuarioId) ||
          (usuarioId == null && postulacion.nombre == nombre)) {
        return postulacion;
      }
    }
    return null;
  }
}
