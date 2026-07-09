import 'dart:io';

import '../../domain/entities/reporte.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../datasources/reporte_remote_datasource.dart';
import '../models/reporte_model.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  final ReporteRemoteDataSource remote;

  ReporteRepositoryImpl(this.remote);

  @override
  Future<void> crearReporte(Reporte reporte) {
    final model = ReporteModel.fromEntity(reporte);
    return remote.crearReporte(model);
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
