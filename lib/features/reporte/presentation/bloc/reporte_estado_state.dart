import '../../domain/entities/reporte_estado.dart';

abstract class ReporteEstadoState {}

class ReporteEstadoInitial extends ReporteEstadoState {}

class ReporteEstadoLoading extends ReporteEstadoState {}

class ReporteEstadoLoaded extends ReporteEstadoState {
  final ReporteEstado reporte;
  ReporteEstadoLoaded(this.reporte);
}

class ReporteTomadoExito extends ReporteEstadoState {
  final ReporteEstado reporte;
  ReporteTomadoExito(this.reporte);
}

class ReporteTomando extends ReporteEstadoState {
  final ReporteEstado reporte;
  ReporteTomando(this.reporte);
}

class ReporteTomarError extends ReporteEstadoState {
  final ReporteEstado reporte;
  final String message;
  ReporteTomarError(this.reporte, this.message);
}

class ReporteEstadoActualizando extends ReporteEstadoState {}

class ReporteEstadoActualizado extends ReporteEstadoState {}

class ReporteEstadoError extends ReporteEstadoState {
  final String message;
  ReporteEstadoError(this.message);
}
