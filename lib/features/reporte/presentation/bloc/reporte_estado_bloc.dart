import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reporte_estado.dart';
import '../../domain/entities/fase_reporte.dart';
import '../../domain/usecases/get_reporte_estado_usecase.dart';
import '../../domain/usecases/actualizar_estado_reporte_usecase.dart';
import 'reporte_estado_event.dart';
import 'reporte_estado_state.dart';

class ReporteEstadoBloc extends Bloc<ReporteEstadoEvent, ReporteEstadoState> {
  final GetReporteEstadoUseCase? getEstado;
  final ActualizarEstadoReporteUseCase? actualizarEstado;

  ReporteEstadoBloc({
    this.getEstado,
    this.actualizarEstado,
  }) : super(ReporteEstadoInitial()) {
    on<CargarEstadoReporte>(_onCargar);
    on<ActualizarEstado>(_onActualizar);
  }

  Future<void> _onCargar(
    CargarEstadoReporte event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    emit(ReporteEstadoLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final reporteDePrueba = _getMockReporte(event.reporteId);
      emit(ReporteEstadoLoaded(reporteDePrueba));
    } catch (e) {
      emit(ReporteEstadoError(e.toString()));
    }
  }

  Future<void> _onActualizar(
    ActualizarEstado event,
    Emitter<ReporteEstadoState> emit,
  ) async {
    emit(ReporteEstadoActualizando());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final exito = DateTime.now().millisecondsSinceEpoch % 2 == 0;
      if (exito) {
        emit(ReporteEstadoActualizado());
      } else {
        throw Exception('Error simulado al actualizar');
      }
    } catch (e) {
      emit(ReporteEstadoError(e.toString()));
    }
  }

  ReporteEstado _getMockReporte(int reporteId) {
    switch (reporteId % 3) {
      case 0:
        return const ReporteEstado(
          reporteId: 1,
          faseActual: FaseReporte.requiereAtencion,
          nivelUrgencia: 'Alta',
          tipoReporte: 'Animal en abandono/riesgo',
          descripcion: 'Perro mediano con herida visible.',
          ubicacion: 'Calle Las Margaritas, Puebla',
          tipoAnimal: 'Perro',
          raza: 'Mestizo',
          tamano: 'Mediano',
          evidenciaUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3QBC5l2NNieIa8Yed76K-vNH4X6B0EmHbLCzN4vtA-g&s=10',
          historialFases: ['Requiere atención'],
        );
      case 1:
        return const ReporteEstado(
          reporteId: 2,
          faseActual: FaseReporte.recibiendoAtencion,
          nivelUrgencia: 'Media',
          tipoReporte: 'Mascota encontrada',
          descripcion: 'Gato pequeño resguardado por vecinos.',
          ubicacion: 'Avenida 5 de Mayo, Puebla',
          tipoAnimal: 'Gato',
          raza: 'Mestizo',
          tamano: 'Pequeño',
          evidenciaUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
          historialFases: ['Requiere atención', 'Recibiendo atención'],
        );
      default:
        return const ReporteEstado(
          reporteId: 3,
          faseActual: FaseReporte.seEncuentraASalvo,
          nivelUrgencia: 'Baja',
          tipoReporte: 'Mascota perdida',
          descripcion: 'Perro grande con collar rojo.',
          ubicacion: 'Mercado Municipal, Puebla',
          tipoAnimal: 'Perro',
          raza: 'Labrador',
          tamano: 'Grande',
          evidenciaUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
          historialFases: ['Requiere atención', 'Recibiendo atención', 'Se encuentra a salvo'],
        );
    }
  }
}