import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/mensaje_error.dart';
import '../../../domain/usecases/obtener_tarjetas_usecase.dart';
import '../../../domain/usecases/guardar_tarjeta_usecase.dart';
import '../../../domain/usecases/eliminar_tarjeta_usecase.dart';
import '../../../domain/usecases/actualizar_tarjeta_usecase.dart';
import '../../../domain/usecases/establecer_predeterminada_usecase.dart';
import 'tarjeta_event.dart';
import 'tarjeta_state.dart';

class TarjetaBloc extends Bloc<TarjetaEvent, TarjetaState> {
  final ObtenerTarjetasUseCase obtenerTarjetas;
  final GuardarTarjetaUseCase guardarTarjeta;
  final EliminarTarjetaUseCase eliminarTarjeta;
  final ActualizarTarjetaUseCase actualizarTarjeta; 
  final EstablecerPredeterminadaUseCase establecerPredeterminada; 

  TarjetaBloc({
    required this.obtenerTarjetas,
    required this.guardarTarjeta,
    required this.eliminarTarjeta,
    required this.actualizarTarjeta, 
    required this.establecerPredeterminada, 
  }) : super(TarjetaInitial()) {
    on<CargarTarjetas>(_onCargarTarjetas);
    on<GuardarNuevaTarjeta>(_onGuardarNuevaTarjeta);
    on<EliminarTarjeta>(_onEliminarTarjeta);
    on<ActualizarTarjeta>(_onActualizarTarjeta); 
    on<EstablecerPredeterminada>(_onEstablecerPredeterminada); 
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
      emit(TarjetaError(mensajeDeError(e)));
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
      emit(TarjetaError(mensajeDeError(e)));
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
      emit(TarjetaError(mensajeDeError(e)));
    }
  }

  // Para editar tarjeta
  Future<void> _onActualizarTarjeta(
    ActualizarTarjeta event,
    Emitter<TarjetaState> emit,
  ) async {
    emit(TarjetaLoading());
    try {
      await actualizarTarjeta(
        tarjetaId: event.tarjetaId,
        titular: event.titular,
        fechaVencimiento: event.fechaVencimiento,
        esPredeterminada: event.esPredeterminada,
      );
      emit(TarjetaEliminada()); 
    } catch (e) {
      emit(TarjetaError(mensajeDeError(e)));
    }
  }

  // Establecer como predeterminada
  Future<void> _onEstablecerPredeterminada(
    EstablecerPredeterminada event,
    Emitter<TarjetaState> emit,
  ) async {
    emit(TarjetaLoading());
    try {
      await establecerPredeterminada(event.tarjetaId);
      // Emitimos TarjetaEliminada como señal de "éxito" para que el Listener recargue la lista
      emit(TarjetaEliminada());
    } catch (e) {
      emit(TarjetaError(mensajeDeError(e)));
    }
  }
}
