import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_reporte_estado_usecase.dart';
import '../../domain/usecases/actualizar_estado_reporte_usecase.dart';
import 'reporte_estado_event.dart';
import 'reporte_estado_state.dart';

class ReporteEstadoBloc extends Bloc<ReporteEstadoEvent, ReporteEstadoState> {
  final GetReporteEstadoUseCase getEstado;
  final ActualizarEstadoReporteUseCase actualizarEstado;

  ReporteEstadoBloc({
    required this.getEstado,
    required this.actualizarEstado,
  }) : super(ReporteEstadoInitial()) {
    on<CargarEstadoReporte>(_onCargar);
    on<ActualizarEstado>(_onActualizar);
  }

  Future<void> _onCargar(
    CargarEstadoReporte event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    emit(ReporteEstadoLoading());
    try {
      final estado = await getEstado(event.reporteId);
      emit(ReporteEstadoLoaded(estado));
    } catch (e) {
      emit(ReporteEstadoError(e.toString()));
    }
  }

  Future<void> _onActualizar(
    ActualizarEstado event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    emit(ReporteEstadoActualizando());
    try {
      await actualizarEstado(
        reporteId: event.reporteId,
        nuevaFaseId: event.nuevaFaseId,
        evidencia: event.evidencia,
      );
      emit(ReporteEstadoActualizado());
    } catch (e) {
      emit(ReporteEstadoError(e.toString()));
    }
  }
}