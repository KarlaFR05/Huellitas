import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../domain/repositories/completar_perfil_repository.dart';
import 'completar_perfil_event.dart';
import 'completar_perfil_state.dart';

class CompletarPerfilBloc
    extends Bloc<CompletarPerfilEvent, CompletarPerfilState> {
  final CompletarPerfilRepository repository;

  CompletarPerfilBloc({required this.repository})
    : super(CompletarPerfilInitial()) {
    on<GuardarDireccionEvent>((event, emit) {
      emit(
        _estadoActual().copyWith(
          estado: event.estado,
          ciudad: event.ciudad,
          cp: event.cp,
          colonia: event.colonia,
          calle: event.calle,
        ),
      );
    });

    on<SubirFrenteEvent>((event, emit) {
      emit(_estadoActual().copyWith(frente: event.imagen));
    });

    on<SubirReversoEvent>((event, emit) {
      emit(_estadoActual().copyWith(reverso: event.imagen));
    });

    on<SubirSelfieEvent>((event, emit) {
      emit(_estadoActual().copyWith(selfie: event.imagen));
    });

    on<EnviarPerfilEvent>((event, emit) async {
      final actual = _estadoActual();

      if (!actual.datosCompletos) {
        emit(CompletarPerfilError('Faltan datos por completar'));
        emit(actual);
        return;
      }

      emit(CompletarPerfilLoading());
      try {
        await repository.completarPerfil(
          calle: actual.calle!,
          colonia: actual.colonia!,
          cp: actual.cp!,
          ciudad: actual.ciudad!,
          estado: actual.estado!,
          frontal: actual.frente!,
          trasera: actual.reverso!,
          selfie: actual.selfie!,
        );
        emit(CompletarPerfilSuccess());
      } catch (e) {
        emit(CompletarPerfilError(mensajeDeError(e)));
      }
    });
  }

  CompletarPerfilLoaded _estadoActual() {
    final s = state;
    return s is CompletarPerfilLoaded ? s : CompletarPerfilLoaded();
  }
}
