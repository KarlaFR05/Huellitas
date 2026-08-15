import '../entities/notificacion.dart';

abstract class NotificacionRepository {
  Future<List<Notificacion>> obtenerNotificaciones();
  Future<void> marcarComoLeida(int notificacionId);
  Future<void> marcarTodasComoLeidas();
  Future<void> guardarFcmToken(String token);
}