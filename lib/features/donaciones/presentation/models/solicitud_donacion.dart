import 'dart:io';
import 'package:flutter/foundation.dart';

class GastoRescate {
  GastoRescate({required this.descripcion, required this.monto, required this.evidencia});

  String descripcion;
  double monto;
  File? evidencia;
}

class SolicitudDonacion {
  SolicitudDonacion({required this.meta, required this.descripcion, required this.gastos, this.totalDonado = 0});

  double meta;
  String descripcion;
  List<GastoRescate> gastos;
  double totalDonado;

  double get totalGastado => gastos.fold(0, (total, gasto) => total + gasto.monto);
}

/// Estado local; todavía no se guarda en la API.
class SolicitudesDonacionStore {
  static final Map<int, SolicitudDonacion> _solicitudes = {};
  static final ValueNotifier<int> cambios = ValueNotifier(0);

  static SolicitudDonacion? obtener(int reporteId) => _solicitudes[reporteId];
  static void guardar(int reporteId, SolicitudDonacion solicitud) {
    _solicitudes[reporteId] = solicitud;
    cambios.value++;
  }

  static void registrarDonacion(int reporteId, double monto) {
    final solicitud = _solicitudes[reporteId];
    if (solicitud == null) return;
    solicitud.totalDonado += monto;
    cambios.value++;
  }
}
