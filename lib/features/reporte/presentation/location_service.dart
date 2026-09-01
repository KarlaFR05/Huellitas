import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  final Dio _dio = Dio();

  Future<Position?> obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw Exception(
        'El GPS está desactivado. Activa la ubicación en tu dispositivo.',
      );
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }
    if (permiso == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación denegado permanentemente. Habilítalo desde Configuración.',
      );
    }

    final ultimaConocida = await Geolocator.getLastKnownPosition();

    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      return posicion;
    } on TimeoutException {
      if (ultimaConocida != null) return ultimaConocida;
      rethrow;
    }
  }

  Future<String> obtenerDireccionDesdeCoordenadas(
    double lat,
    double lng,
  ) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'lat': lat, 'lon': lng, 'format': 'json'},
        options: Options(headers: {'User-Agent': 'com.huellitas.app'}),
      );

      if (response.statusCode == 200 && response.data['display_name'] != null) {
        return response.data['display_name'];
      }
      return 'Ubicación capturada (sin dirección disponible)';
    } catch (e) {
      return 'Ubicación capturada (sin dirección disponible)';
    }
  }

  Stream<Position> obtenerStreamUbicacion() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 8,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
