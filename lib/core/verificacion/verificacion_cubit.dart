import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

enum EstadoVerificacion { noIniciado, enRevision, verificado }

class VerificacionCubit extends Cubit<EstadoVerificacion> {
  Timer? _timer;

  VerificacionCubit() : super(EstadoVerificacion.noIniciado);

  void iniciarRevision() {
    emit(EstadoVerificacion.enRevision);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 30), () {
      emit(EstadoVerificacion.verificado);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
