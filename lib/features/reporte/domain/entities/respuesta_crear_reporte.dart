import 'candidato_duplicado.dart';
import 'reporte.dart';

class RespuestaCrearReporte {
  final bool posibleDuplicado;
  final List<CandidatoDuplicado>? candidatos;
  final Reporte? reporte;

  RespuestaCrearReporte({
    required this.posibleDuplicado,
    this.candidatos,
    this.reporte,
  });
}
