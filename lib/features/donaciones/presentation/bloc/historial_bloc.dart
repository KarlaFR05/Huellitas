import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../domain/entities/categoria_organizacion.dart';
import '../../domain/entities/organizacion.dart';
import '../../domain/usecases/obtener_historial_donaciones_usecase.dart';
import '../../domain/usecases/obtener_organizaciones_usecase.dart';
import 'historial_event.dart';
import 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final ObtenerHistorialDonacionesUseCase obtenerDonaciones;
  final ObtenerOrganizacionesUseCase obtenerOrganizaciones;

  List<Organizacion> _organizacionesCache = [];

  HistorialBloc({
    required this.obtenerDonaciones,
    required this.obtenerOrganizaciones,
  }) : super(HistorialInitial()) {
    on<CargarHistorial>(_onCargarHistorial);
  }

  Future<void> _onCargarHistorial(
    CargarHistorial event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    try {
      switch (event.tipo) {
        case TipoHistorial.donaciones:
          // Cargar organizaciones de forma aislada: si falla, seguimos
          if (_organizacionesCache.isEmpty) {
            try {
              final todas = <Organizacion>[];
              for (final categoria in CategoriaOrganizacion.values) {
                todas.addAll(await obtenerOrganizaciones(categoria));
              }
              _organizacionesCache = todas;
            } catch (e) {
              print('Organizaciones no disponibles: $e');
            }
          }

          final donaciones = await obtenerDonaciones();
          emit(HistorialLoaded(tipo: event.tipo, donaciones: donaciones));
      }
    } catch (e) {
      print('ERROR HISTORIAL: $e');
      emit(HistorialError(mensajeDeError(e)));
    }
  }

  Organizacion? organizacionPorId(int id) {
    for (final org in _organizacionesCache) {
      if (org.id == id) return org;
    }
    return null;
  }
}