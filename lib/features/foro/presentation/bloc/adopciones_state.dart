import '../../domain/entities/adopcion.dart';

enum AdopcionesStatus {
  inicial,
  cargando,
  cargado,
  error,
}

class AdopcionesState {
  const AdopcionesState({
    this.status = AdopcionesStatus.inicial,
    this.adopciones = const [],
    this.mensajeError,
  });

  final AdopcionesStatus status;
  final List<Adopcion> adopciones;
  final String? mensajeError;

  AdopcionesState copyWith({
    AdopcionesStatus? status,
    List<Adopcion>? adopciones,
    String? mensajeError,
    bool limpiarError = false,
  }) {
    return AdopcionesState(
      status: status ?? this.status,
      adopciones: adopciones ?? this.adopciones,
      mensajeError: limpiarError
          ? null
          : mensajeError ?? this.mensajeError,
    );
  }
}