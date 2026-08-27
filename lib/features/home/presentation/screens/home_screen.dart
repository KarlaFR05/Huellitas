import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../home/presentation/widgets/map_widget.dart';
import '../../../home/presentation/widgets/reporte_marker.dart';
import '../../../reporte/data/datasources/reporte_remote_datasource_impl.dart';
import '../../../reporte/data/repositories/reporte_repository_impl.dart';
import '../../../reporte/domain/usecases/get_reportes_usecase.dart';
import '../../../reporte/domain/entities/reporte.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../reporte/presentation/location_service.dart';
import '../widgets/bottom_bar.dart';
import '../../../../core/verificacion/verificacion_cubit.dart';
import '../../../../core/widgets/verificado_badge.dart';
import '../../../../core/widgets/avatar_helper.dart';
import '../../../notificaciones/presentation/widgets/campana_badge.dart';
import '../widgets/filtro_reportes.dart';

const int _faseConcluido = 3;
const Duration _tiempoVisibleTrasConcluir = Duration(seconds: 35);

class HomeScreen extends StatefulWidget {
  final int? reporteIdInicial;

  const HomeScreen({super.key, this.reporteIdInicial});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ReportMapMarker> _markers = [];
  List<ReportMapMarker> _markersVisibles(bool estaVerificado) {
    final ahora = DateTime.now();

    return _markers.where((m) {
      if (!estaVerificado && m.tipoReporte == 'Maltrato animal') {
        return false;
      }

      if (_filtroAnimales.isNotEmpty && !_filtroAnimales.contains(m.animal)) {
        return false;
      }

      if (_filtroUrgencias.isNotEmpty &&
          !_filtroUrgencias.contains(m.urgency)) {
        return false;
      }

      if (m.faseActualId == _faseConcluido) {
        if (_mostrarCompletadosSinLimite) return true;
        if (m.fechaActualizacion == null) return true;
        final tiempoTranscurrido = ahora.difference(m.fechaActualizacion!);
        return tiempoTranscurrido < _tiempoVisibleTrasConcluir;
      }

      return true;
    }).toList();
  }

  Set<ReportAnimal> _filtroAnimales = {};
  Set<ReportUrgency> _filtroUrgencias = {};
  bool _mostrarCompletadosSinLimite = false;

  bool _cargando = true;

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _pollingTimer;
  Timer? _refrescoVisual;
  Timer? _ubicacionThrottle;

  @override
  void initState() {
    super.initState();
    _cargarReportes(esCargaInicial: true);
    _iniciarSeguimientoUbicacion();
    _iniciarPolling();
    _refrescoVisual = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pollingTimer?.cancel();
    _refrescoVisual?.cancel();
    _ubicacionThrottle?.cancel();
    super.dispose();
  }

  void _iniciarPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _cargarReportes();
    });
  }

  Future<void> _iniciarSeguimientoUbicacion() async {
    try {
      await _locationService.obtenerUbicacionActual();

      _positionStream = _locationService.obtenerStreamUbicacion().listen((
        position,
      ) {
        final nuevaUbicacion = LatLng(position.latitude, position.longitude);
        setState(() => _userLocation = nuevaUbicacion);
        _mapController.move(nuevaUbicacion, _mapController.camera.zoom);
        _actualizarUbicacionEnServidor(position);
      });
    } catch (e) {
      print('No se pudo iniciar seguimiento de ubicación: $e');
    }
  }

  void _actualizarUbicacionEnServidor(Position position) {
    if (_ubicacionThrottle != null) return;

    _ubicacionThrottle = Timer(const Duration(minutes: 5), () {
      _ubicacionThrottle = null;
    });

    final dio = context.read<Dio>();
    dio
        .patch(
          '/usuarios/ubicacion',
          data: {'latitud': position.latitude, 'longitud': position.longitude},
        )
        .catchError((e) {
          print('No se pudo actualizar ubicación en el servidor: $e');
        });
  }

  Future<void> _cargarReportes({bool esCargaInicial = false}) async {
    if (esCargaInicial) setState(() => _cargando = true);
    try {
      final dio = context.read<Dio>();

      final repository = ReporteRepositoryImpl(
        ReporteRemoteDataSourceImpl(dio),
      );

      final getReportes = GetReportesUseCase(repository);
      final reportes = await getReportes();

      print(' REPORTES OBTENIDOS: ${reportes.length}');
      for (var r in reportes) {
        print('  - id: ${r.id}, lat: ${r.latitud}, lng: ${r.longitud}');
      }

      setState(() {
        final reportesValidos = reportes
            .where(
              (r) =>
                  r.latitud != 0.0 &&
                  r.longitud != 0.0 &&
                  !r.latitud.isNaN &&
                  !r.longitud.isNaN,
            )
            .toList();

        _markers = reportesValidos.asMap().entries.map((entry) {
          final index = entry.key;
          final reporte = entry.value;

          final reporteConId = reporte.id != null
              ? reporte
              : Reporte(
                  id: index + 1,
                  tipoAnimalId: reporte.tipoAnimalId,
                  tamano: reporte.tamano,
                  tipoReporteId: reporte.tipoReporteId,
                  urgenciaId: reporte.urgenciaId,
                  descripcion: reporte.descripcion,
                  ubicacion: reporte.ubicacion,
                  usuarioId: reporte.usuarioId,
                  raza: reporte.raza,
                  evidencia: reporte.evidencia,
                  latitud: reporte.latitud,
                  longitud: reporte.longitud,
                  faseActualId: reporte.faseActualId,
                  fechaActualizacion: reporte.fechaActualizacion,
                );

          return ReportMapMarker.fromReporte(reporteConId);
        }).toList();
        _cargando = false;
      });
    } catch (e) {
      print('ERROR AL CARGAR REPORTES: $e');
      setState(() => _cargando = false);
    }
  }

  Future<void> _abrirFiltro() async {
    final resultado = await showModalBottomSheet<ResultadoFiltroReportes>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FiltroReportesSheet(
        animalesSeleccionados: _filtroAnimales,
        urgenciasSeleccionadas: _filtroUrgencias,
        mostrarCompletados: _mostrarCompletadosSinLimite,
      ),
    );

    if (resultado != null) {
      setState(() {
        _filtroAnimales = resultado.animales;
        _filtroUrgencias = resultado.urgencias;
        _mostrarCompletadosSinLimite = resultado.mostrarCompletados;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const _Header(),
                Expanded(
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            BlocBuilder<VerificacionCubit, EstadoVerificacion>(
                              builder: (context, estadoVerificacion) {
                                final estaVerificado =
                                    estadoVerificacion ==
                                    EstadoVerificacion.verificado;
                                return MapWidget(
                                  markers: _markersVisibles(estaVerificado),
                                  userLocation: _userLocation,
                                  mapController: _mapController,
                                  reporteIdInicial: widget.reporteIdInicial,
                                );
                              },
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: FiltroReportesButton(
                                cantidadActiva:
                                    _filtroAnimales.length +
                                    _filtroUrgencias.length +
                                    (_mostrarCompletadosSinLimite ? 1 : 0),
                                onTap: _abrirFiltro,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: BottomBarWidget.contentClearance(context),
              child: ElevatedButton(
                onPressed: () {
                  context.push('/report-form');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text(
                  'Realizar Reporte',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 0),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String? fotoPerfil;
              if (state is AuthSuccess && state.data is Usuario) {
                fotoPerfil = (state.data as Usuario).fotoPerfil;
              }
              return CircleAvatar(
                radius: 24,
                backgroundImage: avatarProvider(fotoPerfil),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String nombreUsuario = 'Usuario';
                bool usuarioVerificado = false;

                if (state is AuthSuccess && state.data is Usuario) {
                  final usuario = state.data as Usuario;
                  nombreUsuario = usuario.nombreUsuario.isNotEmpty
                      ? usuario.nombreUsuario
                      : 'Usuario';
                  usuarioVerificado = usuario.verificado;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          nombreUsuario,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        BlocBuilder<VerificacionCubit, EstadoVerificacion>(
                          builder: (context, estadoVerificacion) {
                            final mostrarBadge =
                                usuarioVerificado ||
                                estadoVerificacion ==
                                    EstadoVerificacion.verificado;
                            if (!mostrarBadge) return const SizedBox.shrink();
                            return const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: VerificadoBadge(size: 18),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const CampanaBadge(),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.home_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.chat_bubble_outline,
            color: Theme.of(context).colorScheme.onSurface,
            size: 22,
          ),
          Icon(
            Icons.volunteer_activism_outlined,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
          Icon(
            Icons.person_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
