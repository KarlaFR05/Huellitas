import 'dart:async';

class ProcesarPagoService {
  Future<bool> procesarPago({
    required double monto,
    required int organizacionId,
    required String numeroTarjeta,
    required String titular,
    required String fechaVencimiento,
    String? cvv,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; 
  }
}