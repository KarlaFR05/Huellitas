import '../../domain/entities/catalog.dart';
import '../../domain/entities/candidato_duplicado.dart';

abstract class ReporteState {}

class ReporteInitial extends ReporteState {}

class ReporteLoading extends ReporteState {}

class ReporteSubmitting extends ReporteState {}

class ReporteCatalogsLoaded extends ReporteState {
  final List<Catalog> animalTypes;
  final List<Catalog> reportTypes;
  final List<Catalog> urgencyLevels;

  ReporteCatalogsLoaded({
    required this.animalTypes,
    required this.reportTypes,
    required this.urgencyLevels,
  });
}

class ReporteDuplicadoDetectado extends ReporteState {
  final List<CandidatoDuplicado> candidatos;

  ReporteDuplicadoDetectado({required this.candidatos});
}

class ReporteSuccess extends ReporteState {}

class ReporteError extends ReporteState {
  final String message;
  ReporteError({required this.message});
}
