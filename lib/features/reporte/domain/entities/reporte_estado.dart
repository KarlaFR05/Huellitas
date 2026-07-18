import 'fase_reporte.dart';
import 'historial_fase_item.dart';

class ReporteEstado {
  final int reporteId;
  final FaseReporte faseActual;
  final String nivelUrgencia;
  final String tipoReporte;
  final String descripcion;
  final String ubicacion;
  final String tipoAnimal;
  final String raza;
  final String tamano;
  final String evidenciaUrl;
  final int? usuarioRescateId;
  final String? usuarioRescateNombre;
  final List<HistorialFaseItem> historialFases;
  final String? comentarios;

  const ReporteEstado({
    required this.reporteId,
    required this.faseActual,
    required this.nivelUrgencia,
    required this.tipoReporte,
    required this.descripcion,
    required this.ubicacion,
    required this.tipoAnimal,
    required this.raza,
    required this.tamano,
    required this.evidenciaUrl,
    this.usuarioRescateId,
    this.usuarioRescateNombre,
    this.historialFases = const [],
    this.comentarios,
  });
}
