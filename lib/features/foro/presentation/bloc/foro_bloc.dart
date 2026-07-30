import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';
import 'foro_event.dart';
import 'foro_state.dart';

class ForoBloc extends Bloc<ForoEvent, ForoState> {
  final ForoRepository repository;

  ForoBloc({required this.repository}) : super(const ForoState()) {
    on<ForoFeedSolicitado>(_cargarFeed);
    on<ForoFiltroCambiado>(_cambiarFiltro);
    on<ForoPublicacionCreada>(_crearPublicacion);
    on<ForoMeGustaCambiado>(_cambiarMeGusta);
    on<ForoPublicacionEliminada>(_eliminarPublicacion);
  }

  Future<void> _cargarFeed(
    ForoFeedSolicitado event,
    Emitter<ForoState> emit,
  ) async {
    if (!event.recargar &&
        (!state.hayMas || state.status == ForoStatus.cargando)) {
      return;
    }
    final recargar = event.recargar || state.status == ForoStatus.inicial;
    emit(
      state.copyWith(
        status: ForoStatus.cargando,
        limpiarError: true,
        limpiarCursor: recargar,
      ),
    );
    try {
      final pagina = await repository.obtenerFeed(
        FiltroPublicaciones(
          categoria: state.categoria,
          cursor: recargar ? null : state.siguienteCursor,
        ),
      );
      emit(
        state.copyWith(
          status: ForoStatus.exito,
          publicaciones: recargar
              ? pagina.elementos
              : [...state.publicaciones, ...pagina.elementos],
          siguienteCursor: pagina.siguienteCursor,
          limpiarCursor: pagina.siguienteCursor == null,
          hayMas: pagina.hayMas,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ForoStatus.error,
          mensajeError: error.toString(),
        ),
      );
    }
  }

  Future<void> _cambiarFiltro(
    ForoFiltroCambiado event,
    Emitter<ForoState> emit,
  ) async {
    emit(
      state.copyWith(
        categoria: event.categoria,
        limpiarCategoria: event.categoria == null,
        publicaciones: const [],
        hayMas: true,
        limpiarCursor: true,
      ),
    );
    add(const ForoFeedSolicitado(recargar: true));
  }

  Future<void> _crearPublicacion(
    ForoPublicacionCreada event,
    Emitter<ForoState> emit,
  ) async {
    emit(state.copyWith(publicando: true, limpiarError: true));
    try {
      final publicacion = await repository.crearPublicacion(event.solicitud);
      emit(
        state.copyWith(
          publicando: false,
          status: ForoStatus.exito,
          publicaciones: [publicacion, ...state.publicaciones],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          publicando: false,
          status: ForoStatus.error,
          mensajeError: error.toString(),
        ),
      );
    }
  }

  Future<void> _cambiarMeGusta(
    ForoMeGustaCambiado event,
    Emitter<ForoState> emit,
  ) async {
    final anteriores = state.publicaciones;
    final optimistas = [
      for (final publicacion in anteriores)
        if (publicacion.id == event.publicacionId)
          publicacion.copyWith(
            leGustaAlUsuario: !publicacion.leGustaAlUsuario,
            meGusta:
                publicacion.meGusta + (publicacion.leGustaAlUsuario ? -1 : 1),
          )
        else
          publicacion,
    ];
    emit(state.copyWith(publicaciones: optimistas, limpiarError: true));
    try {
      final actualizada = await repository.cambiarMeGusta(event.publicacionId);
      emit(
        state.copyWith(
          publicaciones: [
            for (final publicacion in state.publicaciones)
              if (publicacion.id == actualizada.id)
                actualizada
              else
                publicacion,
          ],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          publicaciones: anteriores,
          mensajeError: error.toString(),
        ),
      );
    }
  }

  Future<void> _eliminarPublicacion(
    ForoPublicacionEliminada event,
    Emitter<ForoState> emit,
  ) async {
    try {
      await repository.eliminarPublicacion(event.publicacionId);
      emit(
        state.copyWith(
          publicaciones: state.publicaciones
              .where((item) => item.id != event.publicacionId)
              .toList(),
        ),
      );
    } catch (error) {
      emit(state.copyWith(mensajeError: error.toString()));
    }
  }
}
