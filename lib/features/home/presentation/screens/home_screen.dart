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

  ReportUrgency? _filtroUrgencia;

  List<ReportMapMarker> _markersVisibles(bool estaVerificado) {
    final ahora = DateTime.now();

    return _markers.where((m) {
      if (!estaVerificado && m.tipoReporte == 'Maltrato animal') {
        return false;
      }
      if (_filtroUrgencia != null && m.urgency != _filtroUrgencia) {
        return false;
      }

      if (m.faseActualId == _faseConcluido) {
        if (m.fechaActualizacion == null) return true;
        final tiempoTranscurrido = ahora.difference(m.fechaActualizacion!);
        return tiempoTranscurrido < _tiempoVisibleTrasConcluir;
      }

      return true;
    }).toList();
  }

  bool _cargando = true;

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _pollingTimer;
  Timer? _refrescoVisual;

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
      });
    } catch (e) {
      print('No se pudo iniciar seguimiento de ubicación: $e');
    }
  }

  // Abre el panel de filtro
  void _abrirFiltro() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _FiltroSheet(
        seleccionado: _filtroUrgencia,
        onSeleccionar: (urgencia) {
          setState(() => _filtroUrgencia = urgencia);
          Navigator.pop(sheetContext);
        },
      ),
    );
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
                  child: Stack(
                    children: [
                      // Mapa
                      _cargando
                          ? const Center(child: CircularProgressIndicator())
                          : BlocBuilder<VerificacionCubit, EstadoVerificacion>(
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
                        right: 16,
                        child: _BotonFiltrar(
                          seleccionado: _filtroUrgencia,
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

// Botón flotante Filtrar
class _BotonFiltrar extends StatelessWidget {
  final ReportUrgency? seleccionado;
  final VoidCallback onTap;

  const _BotonFiltrar({required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.tune_rounded, color: colors.primary, size: 20),
                  if (seleccionado != null)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: seleccionado!.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.surfaceContainerLowest,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                seleccionado == null ? 'Filtrar' : seleccionado!.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Panel inferior con opciones de urgencia 
class _FiltroSheet extends StatelessWidget {
  final ReportUrgency? seleccionado;
  final ValueChanged<ReportUrgency?> onSeleccionar;

  const _FiltroSheet({
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.tune_rounded, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Filtrar por urgencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Elige qué reportes quieres ver en el mapa',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            _OpcionFiltro(
              label: 'Todas las urgencias',
              color: colors.primary,
              seleccionado: seleccionado == null,
              onTap: () => onSeleccionar(null),
            ),
            const SizedBox(height: 10),

            for (final urgencia in ReportUrgency.values) ...[
              _OpcionFiltro(
                label: 'Urgencia ${urgencia.label.toLowerCase()}',
                color: urgencia.color,
                seleccionado: seleccionado == urgencia,
                onTap: () => onSeleccionar(urgencia),
              ),
              const SizedBox(height: 10),
            ],

            if (seleccionado != null) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => onSeleccionar(null),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Quitar filtro'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpcionFiltro extends StatelessWidget {
  final String label;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _OpcionFiltro({
    required this.label,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: seleccionado
                ? color.withValues(alpha: .12)
                : colors.surfaceContainerHighest.withValues(alpha: .4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: seleccionado ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                seleccionado
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: seleccionado ? color : colors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
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