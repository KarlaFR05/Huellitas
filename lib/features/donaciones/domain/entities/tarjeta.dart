class Tarjeta {
  final int id;
  final int usuarioId;
  final String numeroEnmascarado; // Solo últimos 4 dígitos: "**** **** **** 1234"
  final String numeroCompleto; // Encriptado o solo para uso interno
  final String titular;
  final String fechaVencimiento; // MM/AA
  final String tipo; // "visa", "mastercard", "amex"
  final bool esPredeterminada;
  final DateTime fechaCreacion;

  const Tarjeta({
    required this.id,
    required this.usuarioId,
    required this.numeroEnmascarado,
    required this.numeroCompleto,
    required this.titular,
    required this.fechaVencimiento,
    required this.tipo,
    required this.esPredeterminada,
    required this.fechaCreacion,
  });

  // Obtener el ícono según el tipo de tarjeta
  String get iconoTipo {
    switch (tipo.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return ' Amex';
      default:
        return 'Tarjeta';
    }
  }

  // Determinar el tipo de tarjeta basado en el número
  static String detectarTipo(String numero) {
    final limpio = numero.replaceAll(RegExp(r'\D'), '');
    if (limpio.startsWith('4')) return 'visa';
    if (limpio.startsWith('5') || limpio.startsWith('2')) return 'mastercard';
    if (limpio.startsWith('3')) return 'amex';
    return 'otro';
  }

  // Enmascarar número para mostrar: "**** **** **** 1234"
  static String enmascararNumero(String numeroCompleto) {
    final limpio = numeroCompleto.replaceAll(RegExp(r'\D'), '');
    if (limpio.length < 4) return '****';
    final ultimos4 = limpio.substring(limpio.length - 4);
    return '**** **** **** $ultimos4';
  }
}