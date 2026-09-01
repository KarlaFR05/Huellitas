import '../entities/organizacion_perfil_entity.dart';
import 'package:dio/dio.dart';

abstract class OrganizacionPerfilRepository {
  Future<OrganizacionPerfilEntity> obtenerMiOrganizacion();
  Future<OrganizacionPerfilEntity> actualizarMiOrganizacion(Map<String, dynamic> datos);
  Future<OrganizacionPerfilEntity> subirImagenes({
    MultipartFile? fotoPerfil,
    MultipartFile? fotoPortada,
  });
}