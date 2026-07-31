import 'dart:math';

class ProcesarPagoService {
  /// Simula el procesamiento de un pago.
  /// En producción, aquí iría la llamada al backend/pasarela de pago.
  Future<bool> procesarPago({
    required double monto,
    required int organizacionId,
    required String numeroTarjeta, // Puede ser enmascarado o completo
    required String titular,
    required String fechaVencimiento,
    String? cvv,
  }) async {
    // Simular tiempo de procesamiento (2-4 segundos)
    await Future.delayed(const Duration(seconds: 3));
    
    // Simular resultado: 85% de éxito, 15% de fallo
    final random = Random();
    return random.nextDouble() < 0.85;
  }
}