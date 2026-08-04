import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../domain/usecases/obtener_organizaciones_usecase.dart';
import '../../domain/usecases/crear_donacion_usecase.dart';
import 'donacion_event.dart';
import 'donacion_state.dart';

class DonacionBloc extends Bloc<DonacionEvent, DonacionState> {
  final ObtenerOrganizacionesUseCase obtenerOrganizaciones;
  final CrearDonacionUseCase crearDonacion;

  DonacionBloc({
    required this.obtenerOrganizaciones,
    required this.crearDonacion,
  }) : super(DonacionInitial()) {
    on<CargarOrganizaciones>(_onCargarOrganizaciones);
    on<SeleccionarOrganizacion>(_onSeleccionarOrganizacion);
    on<SeleccionarMonto>(_onSeleccionarMonto);
    on<ProcesarPago>(_onProcesarPago);
  }

  Future<void> _onCargarOrganizaciones(
    CargarOrganizaciones event,
    Emitter<DonacionState> emit,
  ) async {
    emit(DonacionLoading());
    try {
      final organizaciones = await obtenerOrganizaciones(event.categoria);
      emit(DonacionLoaded(organizaciones: organizaciones));
    } catch (e) {
      emit(DonacionError(mensajeDeError(e)));
    }
  }

  Future<void> _onSeleccionarOrganizacion(
    SeleccionarOrganizacion event,
    Emitter<DonacionState> emit,
  ) async {
    if (state is DonacionLoaded) {
      final currentState = state as DonacionLoaded;
      emit(DonacionLoaded(
        organizaciones: currentState.organizaciones,
        organizacionSeleccionada: event.organizacion,
        montoSeleccionado: currentState.montoSeleccionado,
      ));
    }
  }

  Future<void> _onSeleccionarMonto(
    SeleccionarMonto event,
    Emitter<DonacionState> emit,
  ) async {
    if (state is DonacionLoaded) {
      final currentState = state as DonacionLoaded;
      emit(DonacionLoaded(
        organizaciones: currentState.organizaciones,
        organizacionSeleccionada: currentState.organizacionSeleccionada,
        montoSeleccionado: event.monto,
      ));
    }
  }

  Future<void> _onProcesarPago(
    ProcesarPago event,
    Emitter<DonacionState> emit,
  ) async {
    emit(DonacionProcesando());
    try {
      final donacion = await crearDonacion(
        usuarioId: event.usuarioId,
        organizacionId: event.organizacionId,
        monto: event.monto,
        numeroTarjeta: event.numeroTarjeta,
        titularTarjeta: event.titularTarjeta,
        cvv: event.cvv,
        fechaVencimiento: event.fechaVencimiento,
      );
      emit(DonacionCompletada(donacion));
    } catch (e) {
      emit(DonacionError(mensajeDeError(e)));
    }
  }
}
