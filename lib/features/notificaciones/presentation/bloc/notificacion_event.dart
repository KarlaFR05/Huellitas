abstract class NotificacionEvent {}

class CargarNotificaciones extends NotificacionEvent {}
class LimpiarNotificaciones extends NotificacionEvent {}
class MarcarComoLeida extends NotificacionEvent {
  final int notificacionId;
  MarcarComoLeida(this.notificacionId);
}
class MarcarTodasLeidas extends NotificacionEvent {}
class GuardarFcmToken extends NotificacionEvent {
  final String token;
  GuardarFcmToken(this.token);
}
