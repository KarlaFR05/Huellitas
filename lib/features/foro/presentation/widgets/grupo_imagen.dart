import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/grupo.dart';

ImageProvider<Object> imagenPerfilGrupo(Grupo grupo) {
  final local = grupo.fotoPerfilLocalPath;
  return local != null ? FileImage(File(local)) : AssetImage(grupo.fotoPerfil);
}

ImageProvider<Object> imagenPortadaGrupo(Grupo grupo) {
  final local = grupo.fotoPortadaLocalPath;
  return local != null ? FileImage(File(local)) : AssetImage(grupo.fotoPortada);
}

Widget portadaGrupo(
  Grupo grupo, {
  BoxFit fit = BoxFit.cover,
  Alignment alignment = Alignment.center,
}) {
  final local = grupo.fotoPortadaLocalPath;
  return local != null
      ? Image.file(File(local), fit: fit, alignment: alignment)
      : Image.asset(grupo.fotoPortada, fit: fit, alignment: alignment);
}
