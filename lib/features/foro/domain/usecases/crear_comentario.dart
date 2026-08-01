import '../entities/comentario.dart';
import '../entities/solicitudes_foro.dart';
import '../repositories/foro_repository.dart';

class CrearComentario {
  final ForoRepository repository;
  const CrearComentario(this.repository);
  Future<Comentario> call(CrearComentarioSolicitud solicitud) =>
      repository.crearComentario(solicitud);
}