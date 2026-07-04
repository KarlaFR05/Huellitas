import 'package:flutter_bloc/flutter_bloc.dart';

import 'perfil_event.dart';
import 'perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  PerfilBloc() : super(PerfilInitial()) {

    on<CargarPerfilEvent>((event, emit) async {
      emit(PerfilLoading());

    });

    on<EditarPerfilEvent>((event, emit) async {

    });

    on<CompletarPerfilEvent>((event, emit) async {

    });

    on<CerrarSesionEvent>((event, emit) async {
      emit(PerfilLogout());
    });

    on<AbrirInsigniasEvent>((event, emit) {});

    on<AbrirConfiguracionEvent>((event, emit) {});

    on<AbrirAyudaEvent>((event, emit) {});

    on<AbrirPrivacidadEvent>((event, emit) {});
  }
}