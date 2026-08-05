import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/mensaje_error.dart';
import '../../domain/entities/grupo.dart';
import '../../domain/entities/membresia_grupo.dart';
import '../../domain/entities/solicitudes_foro.dart';
import '../../domain/repositories/foro_repository.dart';

sealed class GruposEvent extends Equatable {
  const GruposEvent();

  @override
  List<Object?> get props => [];
}

class GruposSolicitados extends GruposEvent {
  final String? busqueda;

  const GruposSolicitados({this.busqueda});

  @override
  List<Object?> get props => [busqueda];
}

class MisGruposSolicitados extends GruposEvent {
  const MisGruposSolicitados();
}

class GrupoCreado extends GruposEvent {
  final CrearGrupoSolicitud solicitud;

  const GrupoCreado(this.solicitud);

  @override
  List<Object?> get props => [solicitud];
}

class MembresiaGrupoCambiada extends GruposEvent {
  final int grupoId;
  final bool unirse;

  const MembresiaGrupoCambiada({required this.grupoId, required this.unirse});

  @override
  List<Object?> get props => [grupoId, unirse];
}

class SolicitudIngresoEnviada extends GruposEvent {
  final int grupoId;

  const SolicitudIngresoEnviada(this.grupoId);

  @override
  List<Object?> get props => [grupoId];
}

class SolicitudIngresoCancelada extends GruposEvent {
  final int grupoId;

  const SolicitudIngresoCancelada(this.grupoId);

  @override
  List<Object?> get props => [grupoId];
}

class SolicitudesIngresoSolicitadas extends GruposEvent {
  final int grupoId;

  const SolicitudesIngresoSolicitadas(this.grupoId);

  @override
  List<Object?> get props => [grupoId];
}

class MiembrosGrupoSolicitados extends GruposEvent {
  final int grupoId;

  const MiembrosGrupoSolicitados(this.grupoId);

  @override
  List<Object?> get props => [grupoId];
}

class SolicitudIngresoRespondida extends GruposEvent {
  final int grupoId;
  final int usuarioId;
  final bool aceptar;

  const SolicitudIngresoRespondida({
    required this.grupoId,
    required this.usuarioId,
    required this.aceptar,
  });

  @override
  List<Object?> get props => [grupoId, usuarioId, aceptar];
}

class MiembroGrupoEliminado extends GruposEvent {
  final int grupoId;
  final int usuarioId;

  const MiembroGrupoEliminado({required this.grupoId, required this.usuarioId});

  @override
  List<Object?> get props => [grupoId, usuarioId];
}

enum GruposStatus { inicial, cargando, exito, error }

class GruposState extends Equatable {
  final GruposStatus status;
  final List<Grupo> grupos;
  final List<Grupo> misGrupos;
  final String busqueda;
  final int? actualizandoGrupoId;
  final bool creandoGrupo;
  final List<MembresiaGrupo> solicitudesIngreso;
  final List<MembresiaGrupo> miembrosGrupo;
  final bool cargandoAdministracion;
  final int? gestionandoUsuarioId;
  final String? mensajeError;

  const GruposState({
    this.status = GruposStatus.inicial,
    this.grupos = const [],
    this.misGrupos = const [],
    this.busqueda = '',
    this.actualizandoGrupoId,
    this.creandoGrupo = false,
    this.solicitudesIngreso = const [],
    this.miembrosGrupo = const [],
    this.cargandoAdministracion = false,
    this.gestionandoUsuarioId,
    this.mensajeError,
  });

  GruposState copyWith({
    GruposStatus? status,
    List<Grupo>? grupos,
    List<Grupo>? misGrupos,
    String? busqueda,
    int? actualizandoGrupoId,
    bool limpiarGrupoActualizando = false,
    bool? creandoGrupo,
    List<MembresiaGrupo>? solicitudesIngreso,
    List<MembresiaGrupo>? miembrosGrupo,
    bool? cargandoAdministracion,
    int? gestionandoUsuarioId,
    bool limpiarUsuarioGestionado = false,
    String? mensajeError,
    bool limpiarError = false,
  }) {
    return GruposState(
      status: status ?? this.status,
      grupos: grupos ?? this.grupos,
      misGrupos: misGrupos ?? this.misGrupos,
      busqueda: busqueda ?? this.busqueda,
      actualizandoGrupoId: limpiarGrupoActualizando
          ? null
          : actualizandoGrupoId ?? this.actualizandoGrupoId,
      creandoGrupo: creandoGrupo ?? this.creandoGrupo,
      solicitudesIngreso: solicitudesIngreso ?? this.solicitudesIngreso,
      miembrosGrupo: miembrosGrupo ?? this.miembrosGrupo,
      cargandoAdministracion:
          cargandoAdministracion ?? this.cargandoAdministracion,
      gestionandoUsuarioId: limpiarUsuarioGestionado
          ? null
          : gestionandoUsuarioId ?? this.gestionandoUsuarioId,
      mensajeError: limpiarError ? null : mensajeError ?? this.mensajeError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    grupos,
    misGrupos,
    busqueda,
    actualizandoGrupoId,
    creandoGrupo,
    solicitudesIngreso,
    miembrosGrupo,
    cargandoAdministracion,
    gestionandoUsuarioId,
    mensajeError,
  ];
}

class GruposBloc extends Bloc<GruposEvent, GruposState> {
  final ForoRepository repository;

  GruposBloc({required this.repository}) : super(const GruposState()) {
    on<GruposSolicitados>(_cargarGrupos);
    on<MisGruposSolicitados>(_cargarMisGrupos);
    on<GrupoCreado>(_crearGrupo);
    on<MembresiaGrupoCambiada>(_cambiarMembresia);
    on<SolicitudIngresoEnviada>(_solicitarIngreso);
    on<SolicitudIngresoCancelada>(_cancelarSolicitud);
    on<SolicitudesIngresoSolicitadas>(_cargarSolicitudes);
    on<MiembrosGrupoSolicitados>(_cargarMiembros);
    on<SolicitudIngresoRespondida>(_responderSolicitud);
    on<MiembroGrupoEliminado>(_eliminarMiembro);
  }

  Future<void> _cargarGrupos(
    GruposSolicitados event,
    Emitter<GruposState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GruposStatus.cargando,
        busqueda: event.busqueda ?? '',
        limpiarError: true,
      ),
    );
    try {
      final pagina = await repository.obtenerGrupos(busqueda: event.busqueda);
      emit(
        state.copyWith(status: GruposStatus.exito, grupos: pagina.elementos),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GruposStatus.error,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _cargarMisGrupos(
    MisGruposSolicitados event,
    Emitter<GruposState> emit,
  ) async {
    try {
      final grupos = await repository.obtenerMisGrupos();
      emit(state.copyWith(misGrupos: grupos, limpiarError: true));
    } catch (error) {
      emit(state.copyWith(mensajeError: mensajeDeError(error)));
    }
  }

  Future<void> _cambiarMembresia(
    MembresiaGrupoCambiada event,
    Emitter<GruposState> emit,
  ) async {
    emit(
      state.copyWith(actualizandoGrupoId: event.grupoId, limpiarError: true),
    );
    try {
      final actualizado = event.unirse
          ? await repository.unirseAGrupo(event.grupoId)
          : await repository.salirDeGrupo(event.grupoId);
      final grupos = [
        for (final grupo in state.grupos)
          if (grupo.id == actualizado.id) actualizado else grupo,
      ];
      final misGrupos = [
        for (final grupo in state.misGrupos)
          if (grupo.id != actualizado.id) grupo,
        if (actualizado.esMiembro) actualizado,
      ];
      emit(
        state.copyWith(
          grupos: grupos,
          misGrupos: misGrupos,
          limpiarGrupoActualizando: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          limpiarGrupoActualizando: true,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _crearGrupo(GrupoCreado event, Emitter<GruposState> emit) async {
    emit(state.copyWith(creandoGrupo: true, limpiarError: true));
    try {
      final grupo = await repository.crearGrupo(event.solicitud);
      emit(
        state.copyWith(
          creandoGrupo: false,
          grupos: [grupo, ...state.grupos],
          misGrupos: [grupo, ...state.misGrupos],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          creandoGrupo: false,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _solicitarIngreso(
    SolicitudIngresoEnviada event,
    Emitter<GruposState> emit,
  ) async {
    emit(
      state.copyWith(actualizandoGrupoId: event.grupoId, limpiarError: true),
    );
    try {
      final respuesta = await repository.solicitarIngresoGrupo(event.grupoId);
      final actualizado = respuesta.copyWith(solicitudPendiente: true);
      emit(
        state.copyWith(
          grupos: _reemplazarGrupo(state.grupos, actualizado),
          limpiarGrupoActualizando: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          limpiarGrupoActualizando: true,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _cancelarSolicitud(
    SolicitudIngresoCancelada event,
    Emitter<GruposState> emit,
  ) async {
    emit(
      state.copyWith(actualizandoGrupoId: event.grupoId, limpiarError: true),
    );
    try {
      await repository.cancelarSolicitudIngreso(event.grupoId);
      emit(
        state.copyWith(
          grupos: [
            for (final grupo in state.grupos)
              if (grupo.id == event.grupoId)
                grupo.copyWith(solicitudPendiente: false)
              else
                grupo,
          ],
          limpiarGrupoActualizando: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          limpiarGrupoActualizando: true,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _cargarSolicitudes(
    SolicitudesIngresoSolicitadas event,
    Emitter<GruposState> emit,
  ) async {
    emit(state.copyWith(cargandoAdministracion: true, limpiarError: true));
    try {
      final solicitudes = await repository.obtenerSolicitudesIngreso(
        event.grupoId,
      );
      emit(
        state.copyWith(
          cargandoAdministracion: false,
          solicitudesIngreso: solicitudes,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          cargandoAdministracion: false,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _cargarMiembros(
    MiembrosGrupoSolicitados event,
    Emitter<GruposState> emit,
  ) async {
    emit(state.copyWith(cargandoAdministracion: true, limpiarError: true));
    try {
      final miembros = await repository.obtenerMiembrosGrupo(event.grupoId);
      emit(
        state.copyWith(cargandoAdministracion: false, miembrosGrupo: miembros),
      );
    } catch (error) {
      emit(
        state.copyWith(
          cargandoAdministracion: false,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _responderSolicitud(
    SolicitudIngresoRespondida event,
    Emitter<GruposState> emit,
  ) async {
    emit(
      state.copyWith(gestionandoUsuarioId: event.usuarioId, limpiarError: true),
    );
    try {
      await repository.responderSolicitudIngreso(
        grupoId: event.grupoId,
        usuarioId: event.usuarioId,
        aceptar: event.aceptar,
      );
      final solicitud = state.solicitudesIngreso
          .where((item) => item.usuarioId == event.usuarioId)
          .firstOrNull;
      emit(
        state.copyWith(
          solicitudesIngreso: state.solicitudesIngreso
              .where((item) => item.usuarioId != event.usuarioId)
              .toList(),
          miembrosGrupo: event.aceptar && solicitud != null
              ? [...state.miembrosGrupo, solicitud]
              : state.miembrosGrupo,
          limpiarUsuarioGestionado: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          limpiarUsuarioGestionado: true,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  Future<void> _eliminarMiembro(
    MiembroGrupoEliminado event,
    Emitter<GruposState> emit,
  ) async {
    emit(
      state.copyWith(gestionandoUsuarioId: event.usuarioId, limpiarError: true),
    );
    try {
      await repository.eliminarMiembroGrupo(
        grupoId: event.grupoId,
        usuarioId: event.usuarioId,
      );
      emit(
        state.copyWith(
          miembrosGrupo: state.miembrosGrupo
              .where((item) => item.usuarioId != event.usuarioId)
              .toList(),
          limpiarUsuarioGestionado: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          limpiarUsuarioGestionado: true,
          mensajeError: mensajeDeError(error),
        ),
      );
    }
  }

  List<Grupo> _reemplazarGrupo(List<Grupo> grupos, Grupo actualizado) {
    return [
      for (final grupo in grupos)
        if (grupo.id == actualizado.id) actualizado else grupo,
    ];
  }
}
