import 'package:equatable/equatable.dart';

import '../../domain/entities/publicacion.dart';
import '../../domain/entities/solicitudes_foro.dart';

sealed class ForoEvent extends Equatable {
  const ForoEvent();

  @override
  List<Object?> get props => [];
}

class ForoFeedSolicitado extends ForoEvent {
  final bool recargar;

  const ForoFeedSolicitado({this.recargar = false});

  @override
  List<Object?> get props => [recargar];
}

class ForoFiltroCambiado extends ForoEvent {
  final CategoriaPublicacion? categoria;

  const ForoFiltroCambiado(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class ForoPublicacionCreada extends ForoEvent {
  final CrearPublicacionSolicitud solicitud;

  const ForoPublicacionCreada(this.solicitud);

  @override
  List<Object?> get props => [solicitud];
}

class ForoMeGustaCambiado extends ForoEvent {
  final int publicacionId;

  const ForoMeGustaCambiado(this.publicacionId);

  @override
  List<Object?> get props => [publicacionId];
}

class ForoPublicacionEliminada extends ForoEvent {
  final int publicacionId;

  const ForoPublicacionEliminada(this.publicacionId);

  @override
  List<Object?> get props => [publicacionId];
}
