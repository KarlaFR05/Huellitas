import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';
import '../../domain/usecases/get_insignias_usuario_usecase.dart';
import 'insignia_event.dart';
import 'insignia_state.dart';

class InsigniaBloc extends Bloc<InsigniaEvent, InsigniaState> {
  final GetInsigniasUsuarioUseCase getInsignias;

  InsigniaBloc({required this.getInsignias}) : super(InsigniaInitial()) {
    on<CargarInsignias>(_onCargarInsignias);
    on<CambiarFiltroCategoria>(_onCambiarFiltroCategoria);
    on<CambiarTab>(_onCambiarTab);
  }

  Future<void> _onCargarInsignias(
    CargarInsignias event,
    Emitter<InsigniaState> emit,
  ) async {
    emit(InsigniaLoading());
    try {
      print('Solicitando insignias para usuario ${event.usuarioId}...');
      
      final insignias = await getInsignias(event.usuarioId);
      
      print('Insignias obtenidas: ${insignias.length} categorías');
      insignias.forEach((categoria, lista) {
        print('  - $categoria: ${lista.length} insignias');
      });
      
      emit(InsigniaLoaded(todasLasInsignias: insignias));
      
    } catch (e) {
      print('Error en _onCargarInsignias: $e');
      emit(InsigniaError(e.toString()));
    }
  }

  void _onCambiarFiltroCategoria(
    CambiarFiltroCategoria event,
    Emitter<InsigniaState> emit,
  ) {
    if (state is InsigniaLoaded) {
      final currentState = state as InsigniaLoaded;
      emit(currentState.copyWith(categoriaFiltro: () => event.categoria));
    }
  }

  void _onCambiarTab(
    CambiarTab event,
    Emitter<InsigniaState> emit,
  ) {
    if (state is InsigniaLoaded) {
      final currentState = state as InsigniaLoaded;
      emit(currentState.copyWith(mostrarObtenidas: event.mostrarObtenidas));
    }
  }
}