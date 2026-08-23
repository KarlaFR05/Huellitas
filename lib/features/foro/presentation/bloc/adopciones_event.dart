import '../../domain/entities/adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';

abstract class AdopcionesEvent {
  const AdopcionesEvent();
}

/// Carga todas las adopciones.
class AdopcionesSolicitadas extends AdopcionesEvent {
  const AdopcionesSolicitadas({
    this.recargar = false,
  });

  final bool recargar;
}

/// Crea una nueva adopción.
class AdopcionCreada extends AdopcionesEvent {
  const AdopcionCreada(this.solicitud);

  final CrearAdopcionSolicitud solicitud;
}

/// Actualiza una adopción existente.
class AdopcionActualizada extends AdopcionesEvent {
  const AdopcionActualizada(this.solicitud);

  final CrearAdopcionSolicitud solicitud;
}

/// Elimina una adopción.
class AdopcionEliminada extends AdopcionesEvent {
  const AdopcionEliminada(this.adopcion);

  final Adopcion adopcion;
}
