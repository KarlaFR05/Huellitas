import '../../domain/entities/categoria_insignia.dart';

abstract class InsigniaEvent {}

class CargarInsignias extends InsigniaEvent {
  final int usuarioId;
  CargarInsignias(this.usuarioId);
}

class CambiarFiltroCategoria extends InsigniaEvent {
  final CategoriaInsignia? categoria;
  CambiarFiltroCategoria(this.categoria);
}

class CambiarTab extends InsigniaEvent {
  final bool mostrarObtenidas;
  CambiarTab(this.mostrarObtenidas);
}