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
      //  DATOS DE PRUEBA - Eliminar cuando el backend esté listo
      await Future.delayed(const Duration(seconds: 1));
      
      final insigniasDePrueba = <CategoriaInsignia, List<Insignia>>{
        CategoriaInsignia.rescate: [
          Insignia(
            id: 1,
            nombre: 'Primer Rescate',
            nivel: 1,
            categoria: CategoriaInsignia.rescate,
            descripcion: 'Realizaste tu primer rescate',
            obtenida: true,
            fechaObtencion: DateTime(2024, 1, 15),
          ),
          const Insignia(
            id: 2,
            nombre: 'Rescatista 3',
            nivel: 3,
            categoria: CategoriaInsignia.rescate,
            descripcion: '3 rescates realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 3,
            nombre: 'Rescatista 5',
            nivel: 5,
            categoria: CategoriaInsignia.rescate,
            descripcion: '5 rescates realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 4,
            nombre: 'Rescatista 10',
            nivel: 10,
            categoria: CategoriaInsignia.rescate,
            descripcion: '10 rescates realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 5,
            nombre: 'Rescatista 25',
            nivel: 25,
            categoria: CategoriaInsignia.rescate,
            descripcion: '25 rescates realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 6,
            nombre: 'Rescatista 50',
            nivel: 50,
            categoria: CategoriaInsignia.rescate,
            descripcion: '50 rescates realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 7,
            nombre: 'Rescatista 100',
            nivel: 100,
            categoria: CategoriaInsignia.rescate,
            descripcion: '100 rescates realizados',
            obtenida: false,
          ),
        ],
        CategoriaInsignia.donacion: [
          Insignia(
            id: 8,
            nombre: 'Primera Donación',
            nivel: 1,
            categoria: CategoriaInsignia.donacion,
            descripcion: 'Realizaste tu primera donación',
            obtenida: true,
            fechaObtencion: DateTime(2024, 2, 10),
          ),
          const Insignia(
            id: 9,
            nombre: 'Donador 3',
            nivel: 3,
            categoria: CategoriaInsignia.donacion,
            descripcion: '3 donaciones realizadas',
            obtenida: false,
          ),
          const Insignia(
            id: 10,
            nombre: 'Donador 5',
            nivel: 5,
            categoria: CategoriaInsignia.donacion,
            descripcion: '5 donaciones realizadas',
            obtenida: false,
          ),
          const Insignia(
            id: 11,
            nombre: 'Donador 10',
            nivel: 10,
            categoria: CategoriaInsignia.donacion,
            descripcion: '10 donaciones realizadas',
            obtenida: false,
          ),
          const Insignia(
            id: 12,
            nombre: 'Donador 25',
            nivel: 25,
            categoria: CategoriaInsignia.donacion,
            descripcion: '25 donaciones realizadas',
            obtenida: false,
          ),
          const Insignia(
            id: 13,
            nombre: 'Donador 50',
            nivel: 50,
            categoria: CategoriaInsignia.donacion,
            descripcion: '50 donaciones realizadas',
            obtenida: false,
          ),
          const Insignia(
            id: 14,
            nombre: 'Donador 100',
            nivel: 100,
            categoria: CategoriaInsignia.donacion,
            descripcion: '100 donaciones realizadas',
            obtenida: false,
          ),
        ],
        CategoriaInsignia.reporte: [
          Insignia(
            id: 15,
            nombre: 'Primer Reporte',
            nivel: 1,
            categoria: CategoriaInsignia.reporte,
            descripcion: 'Realizaste tu primer reporte',
            obtenida: true,
            fechaObtencion: DateTime(2024, 1, 5),
          ),
          Insignia(
            id: 16,
            nombre: 'Reportero 3',
            nivel: 3,
            categoria: CategoriaInsignia.reporte,
            descripcion: '3 reportes realizados',
            obtenida: true,
            fechaObtencion: DateTime(2024, 2, 1),
          ),
          const Insignia(
            id: 17,
            nombre: 'Reportero 5',
            nivel: 5,
            categoria: CategoriaInsignia.reporte,
            descripcion: '5 reportes realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 18,
            nombre: 'Reportero 10',
            nivel: 10,
            categoria: CategoriaInsignia.reporte,
            descripcion: '10 reportes realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 19,
            nombre: 'Reportero 25',
            nivel: 25,
            categoria: CategoriaInsignia.reporte,
            descripcion: '25 reportes realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 20,
            nombre: 'Reportero 50',
            nivel: 50,
            categoria: CategoriaInsignia.reporte,
            descripcion: '50 reportes realizados',
            obtenida: false,
          ),
          const Insignia(
            id: 21,
            nombre: 'Reportero 100',
            nivel: 100,
            categoria: CategoriaInsignia.reporte,
            descripcion: '100 reportes realizados',
            obtenida: false,
          ),
        ],
      };

      print('Mock data cargada: ${insigniasDePrueba.length} categorías');
      emit(InsigniaLoaded(todasLasInsignias: insigniasDePrueba));
      
      /* 
      // CÓDIGO REAL - Descomentar cuando el backend esté listo:
      final insignias = await getInsignias(event.usuarioId);
      emit(InsigniaLoaded(todasLasInsignias: insignias));
      */
      
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
      emit(currentState.copyWith(categoriaFiltro: event.categoria));
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