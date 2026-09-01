import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/adopciones_repository.dart';
import 'adopciones_event.dart';
import 'adopciones_state.dart';

class AdopcionesBloc
    extends Bloc<AdopcionesEvent, AdopcionesState> {
  AdopcionesBloc({
    required AdopcionesRepository repository,
  })  : _repository = repository,
        super(const AdopcionesState()) {
    on<AdopcionesSolicitadas>(_onSolicitarAdopciones);
    on<AdopcionCreada>(_onCrearAdopcion);
    on<AdopcionActualizada>(_onActualizarAdopcion);
    on<AdopcionEliminada>(_onEliminarAdopcion);
  }

  final AdopcionesRepository _repository;

  Future<void> _onSolicitarAdopciones(
    AdopcionesSolicitadas event,
    Emitter<AdopcionesState> emit,
  ) async {
    if (!event.recargar &&
        state.status == AdopcionesStatus.cargado) {
      return;
    }

    emit(
      state.copyWith(
        status: AdopcionesStatus.cargando,
        limpiarError: true,
      ),
    );

    try {
      final adopciones =
          await _repository.obtenerAdopciones();

      emit(
        state.copyWith(
          status: AdopcionesStatus.cargado,
          adopciones: adopciones,
          limpiarError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdopcionesStatus.error,
          mensajeError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCrearAdopcion(
    AdopcionCreada event,
    Emitter<AdopcionesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: AdopcionesStatus.cargando,
        ),
      );

      await _repository.crearAdopcion(event.solicitud);

      add(const AdopcionesSolicitadas(recargar: true));
    } catch (e) {
      emit(
        state.copyWith(
          status: AdopcionesStatus.error,
          mensajeError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onActualizarAdopcion(
    AdopcionActualizada event,
    Emitter<AdopcionesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: AdopcionesStatus.cargando,
        ),
      );

      await _repository.actualizarAdopcion(event.solicitud);

      add(const AdopcionesSolicitadas(recargar: true));
    } catch (e) {
      emit(
        state.copyWith(
          status: AdopcionesStatus.error,
          mensajeError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onEliminarAdopcion(
    AdopcionEliminada event,
    Emitter<AdopcionesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: AdopcionesStatus.cargando,
        ),
      );

      await _repository.eliminarAdopcion(event.adopcion.id);

      add(const AdopcionesSolicitadas(recargar: true));
    } catch (e) {
      emit(
        state.copyWith(
          status: AdopcionesStatus.error,
          mensajeError: e.toString(),
        ),
      );
    }
  }
}
