import '../../domain/entities/reporte_estado.dart';

abstract class ReporteEstadoState {}

class ReporteEstadoInitial extends ReporteEstadoState {}

class ReporteEstadoLoading extends ReporteEstadoState {}

class ReporteEstadoLoaded extends ReporteEstadoState {
  final ReporteEstado reporte;
  ReporteEstadoLoaded(this.reporte);
}

class ReporteEstadoActualizando extends ReporteEstadoState {}

class ReporteEstadoActualizado extends ReporteEstadoState {}

class ReporteEstadoError extends ReporteEstadoState {
  final String message;
  ReporteEstadoError(this.message);
}