import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../domain/entities/reporte_estado.dart';
import '../../domain/usecases/get_reporte_estado_usecase.dart';
import '../../domain/usecases/tomar_reporte_usecase.dart';
import '../../domain/usecases/actualizar_estado_reporte_usecase.dart';
import 'reporte_estado_event.dart';
import 'reporte_estado_state.dart';

class ReporteEstadoBloc extends Bloc<ReporteEstadoEvent, ReporteEstadoState> {
  final GetReporteEstadoUseCase getEstado;
  final TomarReporteUseCase tomarReporte;
  final ActualizarEstadoReporteUseCase actualizarEstado;

  ReporteEstadoBloc({
    required this.getEstado,
    required this.tomarReporte,
    required this.actualizarEstado,
  }) : super(ReporteEstadoInitial()) {
    on<CargarEstadoReporte>(_onCargar);
    on<TomarReporte>(_onTomar);
    on<ActualizarEstado>(_onActualizar);
  }

  Future<void> _onCargar(
    CargarEstadoReporte event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    emit(ReporteEstadoLoading());
    try {
      final reporte = await getEstado(event.reporteId);
      emit(ReporteEstadoLoaded(reporte));
    } catch (e) {
      print('Error en _onCargar: $e');
      emit(ReporteEstadoError(mensajeDeError(e)));
    }
  }

  Future<void> _onTomar(
    TomarReporte event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    final currentState = state;
    ReporteEstado? reporteActual;
    if (currentState is ReporteEstadoLoaded)
      reporteActual = currentState.reporte;
    if (currentState is ReporteTomarError) reporteActual = currentState.reporte;
    if (reporteActual == null) return;

    emit(ReporteTomando(reporteActual));
    try {
      await tomarReporte(event.reporteId);
      final reporteActualizado = await getEstado(event.reporteId);
      emit(ReporteTomadoExito(reporteActualizado));
    } catch (e) {
      print('Error en _onTomar: $e');
      emit(ReporteTomarError(reporteActual, _extraerMensaje(e)));
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
        usuarioId: event.usuarioId,
        evidencia: event.evidencia,
        comentarios: event.comentarios,
      );
      emit(ReporteEstadoActualizado());
    } catch (e) {
      print('Error en _onActualizar: $e');
      emit(ReporteEstadoError(mensajeDeError(e)));
    }
  }

  String _extraerMensaje(Object e) {
    return mensajeDeError(e);
  }
}
