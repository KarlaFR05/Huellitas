import 'dart:io';
import '../../domain/entities/reporte.dart';

abstract class ReporteEvent {}

class LoadCatalogsEvent extends ReporteEvent {}

class SubmitReporte extends ReporteEvent {
  final Reporte reporte;
  final List<File> imagenes;

  SubmitReporte(this.reporte, this.imagenes);
}

class ConfirmarCreacionForzada extends ReporteEvent {}

class CancelarCreacionPorDuplicado extends ReporteEvent {}
