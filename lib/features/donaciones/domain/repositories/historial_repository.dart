import '../entities/donacion.dart';

abstract class HistorialRepository {
  Future<List<Donacion>> obtenerDonacionesUsuario();
}