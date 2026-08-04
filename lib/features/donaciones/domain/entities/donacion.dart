import 'package:flutter/material.dart';

class Donacion {
  final int id;
  final int usuarioId;
  final int organizacionId;
  final double monto;
  /*final String numeroTarjeta;
  final String titularTarjeta;
  final String cvv;
  final String fechaVencimiento;*/
  final int tarjetaId;
  final String metodoPago;
  final DateTime fechaDonacion;
  final String estado;

  const Donacion({
    required this.id,
    required this.usuarioId,
    required this.organizacionId,
    required this.monto,
    required this.tarjetaId,
    required this.metodoPago,
    required this.fechaDonacion,
    required this.estado,
  });
}