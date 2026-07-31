import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/obtener_tarjetas_usecase.dart';
import '../../../domain/usecases/guardar_tarjeta_usecase.dart';
import '../../../domain/usecases/eliminar_tarjeta_usecase.dart';
import 'tarjeta_event.dart';
import 'tarjeta_state.dart';

class TarjetaBloc extends Bloc<TarjetaEvent, TarjetaState> {
  final ObtenerTarjetasUseCase obtenerTarjetas;
  final GuardarTarjetaUseCase guardarTarjeta;
  final EliminarTarjetaUseCase eliminarTarjeta;

  TarjetaBloc({
    required this.obtenerTarjetas,
    required this.guardarTarjeta,
    required this.eliminarTarjeta,
  }) : super(TarjetaInitial()) {
    on<CargarTarjetas>(_onCargarTarjetas);
    on<GuardarNuevaTarjeta>(_onGuardarNuevaTarjeta);
    on<EliminarTarjeta>(_onEliminarTarjeta);
  }

  Future<void> _onCargarTarjetas(
    CargarTarjetas event,
    Emitter<TarjetaState> emit,
  ) async {
    emit(TarjetaLoading());
    try {
      final tarjetas = await obtenerTarjetas(event.usuarioId);
      final predeterminada = tarjetas.where((t) => t.esPredeterminada).firstOrNull;
      emit(TarjetaLoaded(
        tarjetas: tarjetas,
        tarjetaPredeterminada: predeterminada,
      ));
    } catch (e) {
      emit(TarjetaError(e.toString()));
    }
  }

  Future<void> _onGuardarNuevaTarjeta(
    GuardarNuevaTarjeta event,
    Emitter<TarjetaState> emit,
  ) async {
    emit(TarjetaLoading());
    try {
      final tarjeta = await guardarTarjeta(
        usuarioId: event.usuarioId,
        numeroTarjeta: event.numeroTarjeta,
        titular: event.titular,
        fechaVencimiento: event.fechaVencimiento,
        cvv: event.cvv,
        esPredeterminada: event.esPredeterminada,
      );
      emit(TarjetaGuardada(tarjeta));
      add(CargarTarjetas(event.usuarioId));
    } catch (e) {
      emit(TarjetaError(e.toString()));
    }
  }

  Future<void> _onEliminarTarjeta(
    EliminarTarjeta event,
    Emitter<TarjetaState> emit,
  ) async {
    emit(TarjetaLoading());
    try {
      await eliminarTarjeta(event.tarjetaId);
      emit(TarjetaEliminada());
    } catch (e) {
      emit(TarjetaError(e.toString()));
    }
  }
}