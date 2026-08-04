import 'package:equatable/equatable.dart';

import '../../domain/entities/publicacion.dart';

enum ForoStatus { inicial, cargando, exito, error }

class ForoState extends Equatable {
  final ForoStatus status;
  final List<Publicacion> publicaciones;
  final CategoriaPublicacion? categoria;
  final String? siguienteCursor;
  final bool hayMas;
  final bool publicando;
  final String? mensajeError;

  const ForoState({
    this.status = ForoStatus.inicial,
    this.publicaciones = const [],
    this.categoria,
    this.siguienteCursor,
    this.hayMas = true,
    this.publicando = false,
    this.mensajeError,
  });

  ForoState copyWith({
    ForoStatus? status,
    List<Publicacion>? publicaciones,
    CategoriaPublicacion? categoria,
    bool limpiarCategoria = false,
    String? siguienteCursor,
    bool limpiarCursor = false,
    bool? hayMas,
    bool? publicando,
    String? mensajeError,
    bool limpiarError = false,
  }) {
    return ForoState(
      status: status ?? this.status,
      publicaciones: publicaciones ?? this.publicaciones,
      categoria: limpiarCategoria ? null : categoria ?? this.categoria,
      siguienteCursor: limpiarCursor
          ? null
          : siguienteCursor ?? this.siguienteCursor,
      hayMas: hayMas ?? this.hayMas,
      publicando: publicando ?? this.publicando,
      mensajeError: limpiarError ? null : mensajeError ?? this.mensajeError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    publicaciones,
    categoria,
    siguienteCursor,
    hayMas,
    publicando,
    mensajeError,
  ];
}
