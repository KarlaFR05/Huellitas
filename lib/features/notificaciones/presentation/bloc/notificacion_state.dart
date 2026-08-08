import '../../domain/entities/notificacion.dart';

abstract class NotificacionState {}

class NotificacionInitial extends NotificacionState {}
class NotificacionLoading extends NotificacionState {}

class NotificacionLoaded extends NotificacionState {
  final List<Notificacion> notificaciones;
  NotificacionLoaded(this.notificaciones);

  int get noLeidas => notificaciones.where((n) => !n.leida).length;
}

class NotificacionError extends NotificacionState {
  final String message;
  NotificacionError(this.message);
}