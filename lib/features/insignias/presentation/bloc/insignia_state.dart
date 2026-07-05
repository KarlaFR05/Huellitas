import '../../domain/entities/insignia.dart';
import '../../domain/entities/categoria_insignia.dart';

abstract class InsigniaState {}

class InsigniaInitial extends InsigniaState {}

class InsigniaLoading extends InsigniaState {}

class InsigniaLoaded extends InsigniaState {
  final Map<CategoriaInsignia, List<Insignia>> todasLasInsignias;
  final CategoriaInsignia? categoriaFiltro;
  final bool mostrarObtenidas;

  InsigniaLoaded({
    required this.todasLasInsignias,
    this.categoriaFiltro,
    this.mostrarObtenidas = true,
  });

  List<Insignia> get insigniasFiltradas {
    List<Insignia> insignias = [];
    
    if (categoriaFiltro != null) {
      insignias = todasLasInsignias[categoriaFiltro] ?? [];
    } else {
      todasLasInsignias.forEach((_, lista) => insignias.addAll(lista));
    }
    
    return mostrarObtenidas 
        ? insignias.where((i) => i.obtenida).toList()
        : insignias.where((i) => !i.obtenida).toList();
  }

  InsigniaLoaded copyWith({
    Map<CategoriaInsignia, List<Insignia>>? todasLasInsignias,
    CategoriaInsignia? categoriaFiltro,
    bool? mostrarObtenidas,
  }) {
    return InsigniaLoaded(
      todasLasInsignias: todasLasInsignias ?? this.todasLasInsignias,
      categoriaFiltro: categoriaFiltro ?? this.categoriaFiltro,
      mostrarObtenidas: mostrarObtenidas ?? this.mostrarObtenidas,
    );
  }
}

class InsigniaError extends InsigniaState {
  final String message;
  InsigniaError(this.message);
}