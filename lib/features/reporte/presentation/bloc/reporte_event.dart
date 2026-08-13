import 'dart:io';
import '../../domain/entities/reporte.dart';

abstract class ReporteEvent {}

class LoadCatalogsEvent extends ReporteEvent {}

class SubmitReporte extends ReporteEvent {
  final Reporte reporte;
  final List<File> imagenes;

  SubmitReporte(this.reporte, this.imagenes);
}

/// Se dispara cuando el usuario confirma en el diálogo que el reporte
/// NO es un duplicado y quiere continuar de todas formas.
class ConfirmarCreacionForzada extends ReporteEvent {}

/// Se dispara cuando el usuario confirma que SÍ es el mismo animal
/// y decide cancelar la creación del nuevo reporte.
class CancelarCreacionPorDuplicado extends ReporteEvent {}
