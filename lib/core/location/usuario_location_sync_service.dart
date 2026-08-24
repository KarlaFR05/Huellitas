import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class UsuarioLocationSyncService {
  UsuarioLocationSyncService(this._dio);

  final Dio _dio;

  Future<bool> sincronizar() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return false;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      await _dio.patch(
        '/usuarios/ubicacion',
        data: {
          'latitud': posicion.latitude,
          'longitud': posicion.longitude,
        },
      );
      return true;
    } catch (_) {
      // La ubicación mejora las notificaciones cercanas, pero no debe impedir
      // que el usuario use la aplicación si el GPS o la red fallan.
      return false;
    }
  }
}
