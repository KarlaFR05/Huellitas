import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import 'reporte_event.dart';
import 'reporte_state.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/usecases/create_reporte_usecase.dart';
import '../../domain/usecases/get_animal_types.dart';
import '../../domain/usecases/get_report_types.dart';
import '../../domain/usecases/get_urgency_levels.dart';

class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  final CreateReporteUseCase crearReporte;
  final GetAnimalTypes getAnimalTypes;
  final GetReportTypes getReportTypes;
  final GetUrgencyLevels getUrgencyLevels;

  // Se conserva para reintentar sin volver a subir la evidencia.
  Reporte? _ultimoReporteConEvidencia;

  ReporteBloc({
    required this.crearReporte,
    required this.getAnimalTypes,
    required this.getReportTypes,
    required this.getUrgencyLevels,
  }) : super(ReporteInitial()) {
    on<LoadCatalogsEvent>(_onLoadCatalogs);
    on<SubmitReporte>(_onSubmitReporte);
    on<ConfirmarCreacionForzada>(_onConfirmarCreacionForzada);
    on<CancelarCreacionPorDuplicado>(_onCancelarCreacionPorDuplicado);
  }

  Future<void> _onLoadCatalogs(
    LoadCatalogsEvent event,
    Emitter<ReporteState> emit,
  ) async {
    emit(ReporteLoading());

    try {
      final animalTypes = await getAnimalTypes();
      final reportTypes = await getReportTypes();
      final urgencyLevels = await getUrgencyLevels();

      emit(
        ReporteCatalogsLoaded(
          animalTypes: animalTypes,
          reportTypes: reportTypes,
          urgencyLevels: urgencyLevels,
        ),
      );
    } catch (e) {
      emit(ReporteError(message: mensajeDeError(e)));
    }
  }

  Future<void> _onSubmitReporte(
    SubmitReporte event,
    Emitter<ReporteState> emit,
  ) async {
    emit(ReporteSubmitting());

    try {
      final resultado = await crearReporte(event.reporte, event.imagenes);

      if (resultado.respuesta.posibleDuplicado) {
        _ultimoReporteConEvidencia = resultado.reporteConEvidencia;
        emit(
          ReporteDuplicadoDetectado(
            candidatos: resultado.respuesta.candidatos ?? [],
          ),
        );
        return;
      }

      emit(ReporteSuccess());
    } catch (e) {
      emit(ReporteError(message: mensajeDeError(e)));
    }
  }

  Future<void> _onConfirmarCreacionForzada(
    ConfirmarCreacionForzada event,
    Emitter<ReporteState> emit,
  ) async {
    if (_ultimoReporteConEvidencia == null) {
      emit(
        ReporteError(message: 'No hay un reporte pendiente para confirmar.'),
      );
      return;
    }

    emit(ReporteSubmitting());

    try {
      await crearReporte(
        _ultimoReporteConEvidencia!,
        [], // no hay imágenes que subir: reporte.evidencia ya trae la URL
        forzarCreacion: true,
      );

      emit(ReporteSuccess());
    } catch (e) {
      emit(ReporteError(message: e.toString()));
    } finally {
      _ultimoReporteConEvidencia = null;
    }
  }

  void _onCancelarCreacionPorDuplicado(
    CancelarCreacionPorDuplicado event,
    Emitter<ReporteState> emit,
  ) {
    _ultimoReporteConEvidencia = null;
    emit(ReporteInitial());
  }
}
