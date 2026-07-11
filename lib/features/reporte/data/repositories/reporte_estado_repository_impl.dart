import 'dart:io';
import '../../domain/entities/reporte_estado.dart';
import '../../domain/repositories/reporte_estado_repository.dart';
import '../datasources/reporte_estado_remote_datasource.dart';

class ReporteEstadoRepositoryImpl implements ReporteEstadoRepository {
  final ReporteEstadoRemoteDataSource remoteDatasource;

  ReporteEstadoRepositoryImpl(this.remoteDatasource);

  @override
  Future<ReporteEstado> obtenerEstado(int reporteId) async {
    return await remoteDatasource.obtenerEstado(reporteId);
  }

  @override
  Future<void> actualizarEstado({
    required int reporteId,
    required int nuevaFaseId,
    int? usuarioId,
    required File evidencia,
    String? comentarios,
  }) async {
    await remoteDatasource.actualizarEstado(
      reporteId: reporteId,
      nuevaFaseId: nuevaFaseId,
      usuarioId: usuarioId,
      evidencia: evidencia,
      comentarios: comentarios,
    );
  }
}