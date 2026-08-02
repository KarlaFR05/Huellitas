// lib/features/foro/foro_injection.dart
import 'package:dio/dio.dart';
import 'data/datasources/foro_remote_datasource.dart';
import 'data/datasources/foro_remote_datasource_impl.dart';
import 'data/repositories/foro_repository_impl.dart';
import 'domain/repositories/foro_repository.dart';
import 'domain/usecases/crear_publicacion.dart';
import 'domain/usecases/obtener_feed_foro.dart';
import 'domain/usecases/obtener_publicacion.dart';
import 'domain/usecases/toggle_me_gusta.dart';
import 'domain/usecases/obtener_comentarios.dart';
import 'domain/usecases/crear_comentario.dart';
import 'domain/usecases/obtener_grupos.dart';
import 'domain/usecases/obtener_mis_grupos.dart';
import 'domain/usecases/crear_grupo.dart';
import 'domain/usecases/actualizar_grupo.dart';
import 'domain/usecases/unirse_a_grupo.dart';
import 'domain/usecases/solicitar_ingreso_grupo.dart';
import 'domain/usecases/eliminar_publicacion.dart';

class ForoInjection {
  static ForoRemoteDataSource? _remoteDataSource;
  static ForoRepository? _repository;

  static ForoRemoteDataSource remoteDataSource(Dio dio) {
    _remoteDataSource ??= ForoRemoteDataSourceImpl(dio);
    return _remoteDataSource!;
  }

  static ForoRepository repository(Dio dio) {
    _repository ??= ForoRepositoryImpl(remoteDataSource(dio));
    return _repository!;
  }

  // Use cases
  static CrearPublicacion crearPublicacion(Dio dio) =>
      CrearPublicacion(repository(dio));
  static ObtenerFeedForo obtenerFeedForo(Dio dio) =>
      ObtenerFeedForo(repository(dio));
  static ObtenerPublicacion obtenerPublicacion(Dio dio) =>
      ObtenerPublicacion(repository(dio));
  static ToggleMeGusta toggleMeGusta(Dio dio) => ToggleMeGusta(repository(dio));
  static ObtenerComentarios obtenerComentarios(Dio dio) =>
      ObtenerComentarios(repository(dio));
  static CrearComentario crearComentario(Dio dio) =>
      CrearComentario(repository(dio));
  static ObtenerGrupos obtenerGrupos(Dio dio) => ObtenerGrupos(repository(dio));
  static ObtenerMisGrupos obtenerMisGrupos(Dio dio) =>
      ObtenerMisGrupos(repository(dio));
  static CrearGrupo crearGrupo(Dio dio) => CrearGrupo(repository(dio));
  static ActualizarGrupo actualizarGrupo(Dio dio) =>
      ActualizarGrupo(repository(dio));
  static UnirseAGrupo unirseAGrupo(Dio dio) => UnirseAGrupo(repository(dio));
  static SolicitarIngresoGrupo solicitarIngresoGrupo(Dio dio) =>
      SolicitarIngresoGrupo(repository(dio));
  static EliminarPublicacion eliminarPublicacion(Dio dio) =>
      EliminarPublicacion(repository(dio));
}
