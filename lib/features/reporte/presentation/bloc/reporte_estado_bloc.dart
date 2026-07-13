import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reporte_estado.dart';
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
      print('Solicitando estado del reporte ${event.reporteId}...');
      
      final reporte = await getEstado(event.reporteId);
      
      print('Reporte obtenido:');
      print('  - ID: ${reporte.reporteId}');
      print('  - Fase actual: ${reporte.faseActual}');
      print('  - Tipo: ${reporte.tipoReporte}');
      print('  - Urgencia: ${reporte.nivelUrgencia}');
      
      emit(ReporteEstadoLoaded(reporte));
    } catch (e) {
      print('Error en _onCargar: $e');
      emit(ReporteEstadoError(e.toString()));
    }
  }

  Future<void> _onActualizar(
    ActualizarEstado event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    emit(ReporteEstadoActualizando());
    try {
      print('Actualizando estado del reporte ${event.reporteId}...');
      print('  - Nueva fase: ${event.nuevaFaseId}');
      
      await actualizarEstado(
        reporteId: event.reporteId,
        nuevaFaseId: event.nuevaFaseId,
        usuarioId: event.usuarioId,
        evidencia: event.evidencia,
        comentarios: event.comentarios,
      );
      
      print('Estado actualizado correctamente');
      emit(ReporteEstadoActualizado());
    } catch (e) {
      print('Error en _onActualizar: $e');
      emit(ReporteEstadoError(e.toString()));
    }
  }
}