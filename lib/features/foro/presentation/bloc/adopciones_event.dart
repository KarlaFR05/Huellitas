import '../../domain/entities/adopcion.dart';
import '../../domain/repositories/crear_adopcion_solicitud.dart';

abstract class AdopcionesEvent {
  const AdopcionesEvent();
}

class AdopcionesSolicitadas extends AdopcionesEvent {
  const AdopcionesSolicitadas({
    this.recargar = false,
  });

  final bool recargar;
}

class AdopcionCreada extends AdopcionesEvent {
  const AdopcionCreada(this.solicitud);

  final CrearAdopcionSolicitud solicitud;
}

class AdopcionActualizada extends AdopcionesEvent {
  const AdopcionActualizada(this.solicitud);

  final CrearAdopcionSolicitud solicitud;
}

class AdopcionEliminada extends AdopcionesEvent {
  const AdopcionEliminada(this.adopcion);

  final Adopcion adopcion;
}
