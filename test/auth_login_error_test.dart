import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huellitas/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  group('mapAuthExceptionToMessage', () {
    test('devuelve un mensaje claro para credenciales incorrectas', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/usuarios/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/usuarios/login'),
          statusCode: 401,
          data: {'message': 'Credenciales inválidas'},
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
        mapAuthExceptionToMessage(error),
        'Correo o contraseña incorrectos.',
      );
    });

    test('devuelve un mensaje claro cuando la cuenta no existe', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/usuarios/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/usuarios/login'),
          statusCode: 404,
          data: {'message': 'Usuario no encontrado'},
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
        mapAuthExceptionToMessage(error),
        'No existe una cuenta con ese correo.',
      );
    });
  });
}
