import '../../../domain/entities/tarjeta.dart';

abstract class TarjetaState {}

class TarjetaInitial extends TarjetaState {}

class TarjetaLoading extends TarjetaState {}

class TarjetaLoaded extends TarjetaState {
  final List<Tarjeta> tarjetas;
  final Tarjeta? tarjetaPredeterminada;

  TarjetaLoaded({required this.tarjetas, this.tarjetaPredeterminada});

  TarjetaLoaded copyWith({
    List<Tarjeta>? tarjetas,
    Tarjeta? tarjetaPredeterminada,
  }) {
    return TarjetaLoaded(
      tarjetas: tarjetas ?? this.tarjetas,
      tarjetaPredeterminada: tarjetaPredeterminada ?? this.tarjetaPredeterminada,
    );
  }
}

class TarjetaError extends TarjetaState {
  final String message;
  TarjetaError(this.message);
}

class TarjetaGuardada extends TarjetaState {
  final Tarjeta tarjeta;
  TarjetaGuardada(this.tarjeta);
}

class TarjetaActualizada extends TarjetaState {}

class TarjetaEliminada extends TarjetaState {}