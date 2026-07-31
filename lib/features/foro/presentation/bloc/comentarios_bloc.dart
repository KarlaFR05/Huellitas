import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comentario.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';

sealed class ComentariosEvent extends Equatable {
  const ComentariosEvent();

  @override
  List<Object?> get props => [];
}

class ComentariosSolicitados extends ComentariosEvent {
  final int publicacionId;
  final bool recargar;

  const ComentariosSolicitados({
    required this.publicacionId,
    this.recargar = false,
  });

  @override
  List<Object?> get props => [publicacionId, recargar];
}

class ComentarioEnviado extends ComentariosEvent {
  final CrearComentarioSolicitud solicitud;

  const ComentarioEnviado(this.solicitud);

  @override
  List<Object?> get props => [solicitud];
}

class ComentarioEliminado extends ComentariosEvent {
  final int comentarioId;

  const ComentarioEliminado(this.comentarioId);

  @override
  List<Object?> get props => [comentarioId];
}

enum ComentariosStatus { inicial, cargando, exito, error }

class ComentariosState extends Equatable {
  final ComentariosStatus status;
  final int? publicacionId;
  final List<Comentario> comentarios;
  final String? siguienteCursor;
  final bool hayMas;
  final bool enviando;
  final String? mensajeError;

  const ComentariosState({
    this.status = ComentariosStatus.inicial,
    this.publicacionId,
    this.comentarios = const [],
    this.siguienteCursor,
    this.hayMas = true,
    this.enviando = false,
    this.mensajeError,
  });

  ComentariosState copyWith({
    ComentariosStatus? status,
    int? publicacionId,
    List<Comentario>? comentarios,
    String? siguienteCursor,
    bool limpiarCursor = false,
    bool? hayMas,
    bool? enviando,
    String? mensajeError,
    bool limpiarError = false,
  }) {
    return ComentariosState(
      status: status ?? this.status,
      publicacionId: publicacionId ?? this.publicacionId,
      comentarios: comentarios ?? this.comentarios,
      siguienteCursor: limpiarCursor
          ? null
          : siguienteCursor ?? this.siguienteCursor,
      hayMas: hayMas ?? this.hayMas,
      enviando: enviando ?? this.enviando,
      mensajeError: limpiarError ? null : mensajeError ?? this.mensajeError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    publicacionId,
    comentarios,
    siguienteCursor,
    hayMas,
    enviando,
    mensajeError,
  ];
}

class ComentariosBloc extends Bloc<ComentariosEvent, ComentariosState> {
  final ForoRepository repository;

  ComentariosBloc({required this.repository})
    : super(const ComentariosState()) {
    on<ComentariosSolicitados>(_cargar);
    on<ComentarioEnviado>(_enviar);
    on<ComentarioEliminado>(_eliminar);
  }

  Future<void> _cargar(
    ComentariosSolicitados event,
    Emitter<ComentariosState> emit,
  ) async {
    if (!event.recargar &&
        (!state.hayMas || state.status == ComentariosStatus.cargando)) {
      return;
    }
    final recargar =
        event.recargar || state.publicacionId != event.publicacionId;
    emit(
      state.copyWith(
        status: ComentariosStatus.cargando,
        publicacionId: event.publicacionId,
        limpiarCursor: recargar,
        limpiarError: true,
      ),
    );
    try {
      final pagina = await repository.obtenerComentarios(
        event.publicacionId,
        cursor: recargar ? null : state.siguienteCursor,
      );
      emit(
        state.copyWith(
          status: ComentariosStatus.exito,
          comentarios: recargar
              ? pagina.elementos
              : [...state.comentarios, ...pagina.elementos],
          siguienteCursor: pagina.siguienteCursor,
          limpiarCursor: pagina.siguienteCursor == null,
          hayMas: pagina.hayMas,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ComentariosStatus.error,
          mensajeError: error.toString(),
        ),
      );
    }
  }

  Future<void> _enviar(
    ComentarioEnviado event,
    Emitter<ComentariosState> emit,
  ) async {
    emit(state.copyWith(enviando: true, limpiarError: true));
    try {
      final comentario = await repository.crearComentario(event.solicitud);
      emit(
        state.copyWith(
          enviando: false,
          comentarios: [...state.comentarios, comentario],
        ),
      );
    } catch (error) {
      emit(state.copyWith(enviando: false, mensajeError: error.toString()));
    }
  }

  Future<void> _eliminar(
    ComentarioEliminado event,
    Emitter<ComentariosState> emit,
  ) async {
    try {
      await repository.eliminarComentario(event.comentarioId);
      emit(
        state.copyWith(
          comentarios: state.comentarios
              .where((item) => item.id != event.comentarioId)
              .toList(),
        ),
      );
    } catch (error) {
      emit(state.copyWith(mensajeError: error.toString()));
    }
  }
}
