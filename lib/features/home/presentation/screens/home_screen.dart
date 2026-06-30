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
import '../widgets/map_widget.dart';
import '../widgets/reporte_marker.dart';
import '../../../reporte/data/datasources/reporte_remote_datasource_impl.dart';
import '../../../reporte/data/repositories/reporte_repository_impl.dart';
import '../../../reporte/domain/usecases/get_reportes_usecase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../reporte/presentation/location_service.dart';
import '../widgets/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ReportMapMarker> _markers = [];
  bool _cargando = true;

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _cargarReportes(esCargaInicial: true);
    _iniciarSeguimientoUbicacion();
    _iniciarPolling();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // para no dejar el GPS encendido
    _pollingTimer
        ?.cancel(); // importante para no dejarlo corriendo en background
    super.dispose();
  }

  void _iniciarPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _cargarReportes();
    });
  }

  Future<void> _iniciarSeguimientoUbicacion() async {
    try {
      // Solicita permiso una vez (reutiliza lógica que ya tienes)
      await _locationService.obtenerUbicacionActual();

      _positionStream = _locationService.obtenerStreamUbicacion().listen((
        position,
      ) {
        final nuevaUbicacion = LatLng(position.latitude, position.longitude);
        setState(() => _userLocation = nuevaUbicacion);
        _mapController.move(nuevaUbicacion, _mapController.camera.zoom);
      });
    } catch (e) {
      // Si el usuario no da permiso, simplemente no se muestra el punto azul
      print('No se pudo iniciar seguimiento de ubicación: $e');
    }
  }

  Future<void> _cargarReportes({bool esCargaInicial = false}) async {
    if (esCargaInicial) setState(() => _cargando = true);
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://huellitas-backend-xekn.onrender.com',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final repository = ReporteRepositoryImpl(
        ReporteRemoteDataSourceImpl(dio),
      );

      final getReportes = GetReportesUseCase(repository);
      final reportes = await getReportes();

      print('REPORTES OBTENIDOS: ${reportes.length}');
      for (var r in reportes) {
        print('  - lat: ${r.latitud}, lng: ${r.longitud}');
      }

      setState(() {
        _markers = reportes
            .where(
              (r) =>
                  r.latitud != 0.0 &&
                  r.longitud != 0.0 &&
                  !r.latitud.isNaN &&
                  !r.longitud.isNaN,
            )
            .map((r) => ReportMapMarker.fromReporte(r))
            .toList();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _Header(),
                Expanded(
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator())
                      : MapWidget(
                          markers: _markers,
                          userLocation: _userLocation,
                          mapController: _mapController,
                        ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/report-form');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57C29A),
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
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/perfil.png'),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String nombreUsuario = 'Usuario';

                if (state is AuthSuccess && state.data is Usuario) {
                  final usuario = state.data as Usuario;
                  nombreUsuario = usuario.nombre ?? 'Usuario';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      nombreUsuario,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF57C29A),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF57C29A),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
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
        color: const Color(0xFF57C29A),
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home_outlined, color: Colors.white),
          Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
          Icon(
            Icons.volunteer_activism_outlined,
            color: Colors.white,
            size: 28,
          ),
          Icon(Icons.person_outline, color: Colors.white),
        ],
      ),
    );
  }
}
