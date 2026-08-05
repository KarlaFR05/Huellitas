import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/grupo.dart';

ImageProvider<Object> imagenPerfilGrupo(Grupo grupo) {
  final local = grupo.fotoPerfilLocalPath;
  if (local != null) return FileImage(File(local));
  if (grupo.fotoPerfil.startsWith('http')) {
    return NetworkImage(grupo.fotoPerfil);
  }
  return AssetImage(
    grupo.fotoPerfil.isEmpty ? 'assets/images/logoo.png' : grupo.fotoPerfil,
  );
}

ImageProvider<Object> imagenPortadaGrupo(Grupo grupo) {
  final local = grupo.fotoPortadaLocalPath;
  if (local != null) return FileImage(File(local));
  if (grupo.fotoPortada.startsWith('http')) {
    return NetworkImage(grupo.fotoPortada);
  }
  return AssetImage(
    grupo.fotoPortada.isEmpty ? 'assets/images/logoo.png' : grupo.fotoPortada,
  );
}

Widget portadaGrupo(
  Grupo grupo, {
  BoxFit fit = BoxFit.cover,
  Alignment alignment = Alignment.center,
}) {
  final local = grupo.fotoPortadaLocalPath;
  if (local != null) {
    return Image.file(File(local), fit: fit, alignment: alignment);
  }
  if (grupo.fotoPortada.startsWith('http')) {
    return Image.network(grupo.fotoPortada, fit: fit, alignment: alignment);
  }
  if (grupo.fotoPortada.isEmpty) {
    return ColoredBox(color: Colors.green.withValues(alpha: .12));
  }
  return Image.asset(grupo.fotoPortada, fit: fit, alignment: alignment);
}
