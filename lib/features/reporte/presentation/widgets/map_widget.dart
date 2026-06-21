import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final reportLocation = LatLng(
      19.0414,
      -98.2063,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: reportLocation,
        initialZoom: 15,
      ),

      children: [

        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:
              'com.huellitas.app',
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: reportLocation,
              width: 80,
              height: 80,

              child: GestureDetector(
                onTap: () {
                  context.push(
                    '/report-form',
                  );
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
    );
  }
}