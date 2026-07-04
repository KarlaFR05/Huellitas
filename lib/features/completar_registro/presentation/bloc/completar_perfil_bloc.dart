import 'package:flutter_bloc/flutter_bloc.dart';

import 'completar_perfil_event.dart';
import 'completar_perfil_state.dart';

class CompletarPerfilBloc
    extends Bloc<CompletarPerfilEvent, CompletarPerfilState> {

  CompletarPerfilBloc()
      : super(CompletarPerfilInitial()) {

    on<GuardarDireccionEvent>((event, emit) {
    });

    on<SubirFrenteEvent>((event, emit) {
      emit(
        CompletarPerfilLoaded(
          frente: event.imagen,
        ),
      );
    });

    on<SubirReversoEvent>((event, emit) {
      emit(
        CompletarPerfilLoaded(
          reverso: event.imagen,
        ),
      );
    });

    on<SubirSelfieEvent>((event, emit) {
      emit(
        CompletarPerfilLoaded(
          selfie: event.imagen,
        ),
      );
    });

    on<EnviarPerfilEvent>((event, emit) async {
      emit(CompletarPerfilLoading());

      try {

        emit(CompletarPerfilSuccess());
      } catch (e) {
        emit(
          CompletarPerfilError(
            e.toString(),
          ),
        );
      }
    });
  }
}