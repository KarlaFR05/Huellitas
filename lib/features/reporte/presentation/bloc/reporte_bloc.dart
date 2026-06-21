import 'package:flutter_bloc/flutter_bloc.dart';
import 'reporte_event.dart';
import 'reporte_state.dart';
import '../../domain/usecases/create_reporte_usecase.dart';
import '../../domain/usecases/get_animal_types.dart';
import '../../domain/usecases/get_report_types.dart';
import '../../domain/usecases/get_urgency_levels.dart';

class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  final CreateReporteUseCase crearReporte;
  final GetAnimalTypes getAnimalTypes;
  final GetReportTypes getReportTypes;
  final GetUrgencyLevels getUrgencyLevels;

  ReporteBloc({
    required this.crearReporte,
    required this.getAnimalTypes,
    required this.getReportTypes,
    required this.getUrgencyLevels,
  }) : super(ReporteInitial()) {
    on<LoadCatalogsEvent>(_onLoadCatalogs);
    on<SubmitReporte>(_onSubmitReporte);
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
      emit(ReporteError(message: e.toString()));
    }
  }

  Future<void> _onSubmitReporte(
    SubmitReporte event,
    Emitter<ReporteState> emit,
  ) async {
    emit(ReporteSubmitting());

    try {
      await crearReporte(event.reporte, event.imagenes);
      emit(ReporteSuccess());
    } catch (e) {
      emit(ReporteError(message: e.toString()));
    }
  }
}
