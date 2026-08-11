import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificacion_repository.dart';
import '../datasources/notificacion_remote_datasource.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  final NotificacionRemoteDataSource dataSource;
  NotificacionRepositoryImpl(this.dataSource);

  @override
  Future<List<Notificacion>> obtenerNotificaciones() => dataSource.obtenerNotificaciones();

  @override
  Future<void> marcarComoLeida(int id) => dataSource.marcarComoLeida(id);

  @override
  Future<void> marcarTodasComoLeidas() => dataSource.marcarTodasComoLeidas();

  @override
  Future<void> guardarFcmToken(String token) => dataSource.guardarFcmToken(token);
}