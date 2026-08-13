import 'dart:io';

import '../../domain/entities/reporte.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../datasources/reporte_remote_datasource.dart';
import '../models/reporte_model.dart';
import '../../domain/entities/respuesta_crear_reporte.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  final ReporteRemoteDataSource remote;

  ReporteRepositoryImpl(this.remote);

  @override
  Future<RespuestaCrearReporte> crearReporte(
    Reporte reporte, {
    bool forzarCreacion = false,
  }) {
    final model = ReporteModel.fromEntity(reporte);
    return remote.crearReporte(model, forzarCreacion: forzarCreacion);
  }

  @override
  Future<String> subirEvidencia(File imagen) {
    return remote.subirEvidencia(imagen);
  }

  @override
  Future<List<Reporte>> obtenerReportes() {
    return remote.obtenerReportes();
  }
}
