import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/mensaje_error.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificacion_repository.dart';
import 'notificacion_event.dart';
import 'notificacion_state.dart';

class NotificacionBloc extends Bloc<NotificacionEvent, NotificacionState> {
  final NotificacionRepository repository;

  NotificacionBloc({required this.repository}) : super(NotificacionInitial()) {
    on<CargarNotificaciones>(_onCargar);
    on<MarcarComoLeida>(_onMarcarLeida);
    on<MarcarTodasLeidas>(_onMarcarTodas);
    on<GuardarFcmToken>(_onGuardarToken);
  }

  Future<void> _onCargar(CargarNotificaciones event, Emitter<NotificacionState> emit) async {
    emit(NotificacionLoading());
    try {
      final notificaciones = await repository.obtenerNotificaciones();
      emit(NotificacionLoaded(notificaciones));
    } catch (e) {
      emit(NotificacionError(mensajeDeError(e)));
    }
  }

  Future<void> _onMarcarLeida(MarcarComoLeida event, Emitter<NotificacionState> emit) async {
    final estado = state;
    if (estado is! NotificacionLoaded) return;

    try {
      await repository.marcarComoLeida(event.notificacionId);
      final actualizadas = estado.notificaciones.map((n) {
        if (n.id == event.notificacionId) {
          return Notificacion(
            id: n.id, tipo: n.tipo, titulo: n.titulo,
            mensaje: n.mensaje, data: n.data, leida: true,
            creadaEn: n.creadaEn,
          );
        }
        return n;
      }).toList();
      emit(NotificacionLoaded(actualizadas));
    } catch (e) {
      // Conserva las notificaciones cargadas si solo falla esta acción.
      emit(estado);
    }
  }

  Future<void> _onMarcarTodas(MarcarTodasLeidas event, Emitter<NotificacionState> emit) async {
    final estado = state;
    if (estado is! NotificacionLoaded) return;

    try {
      await repository.marcarTodasComoLeidas();
      final actualizadas = estado.notificaciones.map((n) {
        return Notificacion(
          id: n.id, tipo: n.tipo, titulo: n.titulo,
          mensaje: n.mensaje, data: n.data, leida: true,
          creadaEn: n.creadaEn,
        );
      }).toList();
      emit(NotificacionLoaded(actualizadas));
    } catch (e) {
      // Conserva las notificaciones cargadas si solo falla esta acción.
      emit(estado);
    }
  }

  Future<void> _onGuardarToken(GuardarFcmToken event, Emitter<NotificacionState> emit) async {
    try {
      await repository.guardarFcmToken(event.token);
    } catch (e) {
      print('No se pudo guardar FCM token: $e');
    }
  }
}
