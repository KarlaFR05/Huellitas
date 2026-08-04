import 'package:dio/dio.dart';

String mensajeDeError(
  Object error, {
  String mensajePredeterminado = 'Ocurrió un problema. Inténtalo de nuevo.',
}) {
  if (error is! DioException) return mensajePredeterminado;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'La conexión tardó demasiado. Inténtalo nuevamente.';
    case DioExceptionType.connectionError:
      return 'No se pudo conectar con el servidor. Revisa tu conexión.';
    case DioExceptionType.cancel:
      return 'La operación fue cancelada.';
    case DioExceptionType.badCertificate:
      return 'No se pudo establecer una conexión segura.';
    case DioExceptionType.badResponse:
      return _mensajePorEstado(error.response?.statusCode);
    case DioExceptionType.unknown:
      return 'No se pudo completar la operación. Revisa tu conexión.';
  }
}

String _mensajePorEstado(int? estado) {
  switch (estado) {
    case 400:
      return 'Los datos enviados no son válidos. Revisa la información.';
    case 401:
      return 'Tu sesión terminó. Inicia sesión nuevamente.';
    case 403:
      return 'No tienes permiso para realizar esta acción.';
    case 404:
      return 'No se encontró la información solicitada.';
    case 409:
      return 'La operación no pudo completarse porque ya existe un registro similar.';
    case 413:
      return 'El archivo seleccionado es demasiado grande.';
    case 415:
      return 'El formato del archivo no es compatible.';
    case 422:
      return 'Algunos datos no son válidos. Revísalos e inténtalo nuevamente.';
    case 429:
      return 'Realizaste demasiadas solicitudes. Espera un momento.';
    case 500:
    case 502:
    case 503:
    case 504:
      return 'El servidor no está disponible en este momento. Inténtalo más tarde.';
    default:
      return 'No se pudo completar la operación. Inténtalo nuevamente.';
  }
}
