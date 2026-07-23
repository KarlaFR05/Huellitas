import '../../domain/entities/organizacion.dart';
import '../../domain/entities/donacion.dart';

abstract class DonacionState {}

class DonacionInitial extends DonacionState {}

class DonacionLoading extends DonacionState {}

class DonacionLoaded extends DonacionState {
  final List<Organizacion> organizaciones;
  final Organizacion? organizacionSeleccionada;
  final double? montoSeleccionado;

  DonacionLoaded({
    required this.organizaciones,
    this.organizacionSeleccionada,
    this.montoSeleccionado,
  });
}

class DonacionError extends DonacionState {
  final String message;
  DonacionError(this.message);
}

class DonacionProcesando extends DonacionState {}

class DonacionCompletada extends DonacionState {
  final Donacion donacion;
  DonacionCompletada(this.donacion);
}