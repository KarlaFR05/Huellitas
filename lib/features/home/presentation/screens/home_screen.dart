import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../reporte/presentation/report_success_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportLocation = LatLng(19.0414, -98.2063);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _Header(),

                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: reportLocation,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.huellitas.app',
                      ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            point: reportLocation,
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                debugPrint('Reporte seleccionado');
                                context.push('/report-form');
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

      bottomNavigationBar: const _BottomBar(),
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

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Marlene',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
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
          Icon(Icons.notifications_none, color: Colors.white),
          Icon(Icons.assignment_outlined, color: Colors.white),
          Icon(Icons.person_outline, color: Colors.white),
        ],
      ),
    );
  }
}
