import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

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

    const locationSettings = LocationSettings(
      accuracy:
          LocationAccuracy.bestForNavigation, // fuerza uso de GPS real, no red
    );

    Position posicion = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    // Si la precisión sigue siendo mala (radio de error grande), esperamos
    // una lectura mejor del stream de GPS antes de aceptarla.
    if (posicion.accuracy > 30) {
      try {
        posicion =
            await Geolocator.getPositionStream(
                  locationSettings: locationSettings,
                )
                .firstWhere((p) => p.accuracy <= 30)
                .timeout(
                  const Duration(seconds: 8),
                  onTimeout: () =>
                      posicion, // si no mejora a tiempo, usamos la que ya teníamos
                );
      } catch (_) {
        // si el stream falla, seguimos con la posición original
      }
    }

    return posicion;
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
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
