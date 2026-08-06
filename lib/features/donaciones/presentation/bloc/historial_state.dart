import '../../domain/entities/donacion.dart';
import 'historial_event.dart';

abstract class HistorialState {}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialLoaded extends HistorialState {
  final TipoHistorial tipo;
  final List<Donacion> donaciones;

  HistorialLoaded({required this.tipo, required this.donaciones});
}

class HistorialError extends HistorialState {
  final String message;
  HistorialError(this.message);
}