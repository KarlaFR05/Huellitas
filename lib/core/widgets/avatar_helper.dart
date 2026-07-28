import 'package:flutter/material.dart';

ImageProvider avatarProvider(String? fotoPerfil) {
  if (fotoPerfil == null || fotoPerfil.isEmpty) {
    return const AssetImage('assets/images/perfil.jpeg');
  }
  if (fotoPerfil.startsWith('http')) {
    return NetworkImage(fotoPerfil);
  }
  return AssetImage('assets/images/avatares/$fotoPerfil');
}
