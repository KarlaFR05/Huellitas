import '../../domain/entities/organizacion.dart';
import '../../domain/entities/donacion.dart';
import '../../domain/entities/categoria_organizacion.dart';

class DonacionRemoteDataSource {
  // Datos de prueba en memoria
  final List<Organizacion> _organizacionesMock = [
    // Sin Fines De Lucro
    Organizacion(
      id: 1,
      nombre: 'Perritos al rescate',
      descripcion: 'Organización dedicada al rescate de perros en situación de calle',
      logoUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200',
      categoria: CategoriaOrganizacion.sinFinesLucro,
      cuentaBancaria: '1234567890',
    ),
    Organizacion(
      id: 2,
      nombre: 'Rescatando vidas',
      descripcion: 'Refugio para animales abandonados',
      logoUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=200',
      categoria: CategoriaOrganizacion.sinFinesLucro,
      cuentaBancaria: '0987654321',
    ),
    Organizacion(
      id: 3,
      nombre: 'Paw Patrol',
      descripcion: 'Organización de protección animal',
      logoUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=200',
      categoria: CategoriaOrganizacion.sinFinesLucro,
      cuentaBancaria: '1122334455',
    ),
    // Refugios
    Organizacion(
      id: 4,
      nombre: 'Refugio Esperanza',
      descripcion: 'Hogar temporal para mascotas en espera de adopción',
      logoUrl: 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=200',
      categoria: CategoriaOrganizacion.refugios,
      cuentaBancaria: '2233445566',
    ),
    Organizacion(
      id: 5,
      nombre: 'Casa Gatuna',
      descripcion: 'Refugio especializado en gatos',
      logoUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200',
      categoria: CategoriaOrganizacion.refugios,
      cuentaBancaria: '3344556677',
    ),
    Organizacion(
      id: 6,
      nombre: 'Huellitas Felices',
      descripcion: 'Centro de rescate y rehabilitación animal',
      logoUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=200',
      categoria: CategoriaOrganizacion.refugios,
      cuentaBancaria: '4455667788',
    ),
    // Gubernamentales
    Organizacion(
      id: 7,
      nombre: 'Protección Animal Municipal',
      descripcion: 'Programa gubernamental de protección animal',
      logoUrl: 'https://images.unsplash.com/photo-1548802673-380ab8ebc7b7?w=200',
      categoria: CategoriaOrganizacion.gubernamentales,
      cuentaBancaria: '5566778899',
    ),
    Organizacion(
      id: 8,
      nombre: 'Control Animal Estatal',
      descripcion: 'Dependencia estatal de control y bienestar animal',
      logoUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200',
      categoria: CategoriaOrganizacion.gubernamentales,
      cuentaBancaria: '6677889900',
    ),
    Organizacion(
      id: 9,
      nombre: 'Bienestar Animal Federal',
      descripcion: 'Programa federal de bienestar animal',
      logoUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=200',
      categoria: CategoriaOrganizacion.gubernamentales,
      cuentaBancaria: '7788990011',
    ),
  ];

  // Lista para almacenar donaciones en memoria (simula la base de datos)
  final List<Donacion> _donacionesMock = [];
  int _nextId = 1;

  Future<List<Organizacion>> obtenerOrganizaciones(CategoriaOrganizacion categoria) async {
    // Simula un delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _organizacionesMock
        .where((org) => org.categoria == categoria)
        .toList();
  }

  Future<Donacion> crearDonacion({
    required int usuarioId,
    required int organizacionId,
    required double monto,
    required String numeroTarjeta,
    required String titularTarjeta,
    required String cvv,
    required String fechaVencimiento,
  }) async {
    // Simula un delay de red
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Verifica que la organización exista
    final organizacionExiste = _organizacionesMock.any((org) => org.id == organizacionId);
    if (!organizacionExiste) {
      throw Exception('Organización no encontrada');
    }

    // Crea la donación y la guarda en memoria
    final donacion = Donacion(
      id: _nextId++,
      usuarioId: usuarioId,
      organizacionId: organizacionId,
      monto: monto,
      numeroTarjeta: numeroTarjeta,
      titularTarjeta: titularTarjeta,
      cvv: cvv,
      fechaVencimiento: fechaVencimiento,
      fechaDonacion: DateTime.now(),
      estado: 'completada',
    );

    _donacionesMock.add(donacion);
    
    print('Donación registrada en memoria:');
    print('- ID: ${donacion.id}');
    print('- Usuario: ${donacion.usuarioId}');
    print('- Organización: ${donacion.organizacionId}');
    print('- Monto: \$${donacion.monto}');
    print('- Total de donaciones: ${_donacionesMock.length}');
    
    return donacion;
  }

  // Método auxiliar para obtener todas las donaciones (útil para insignias)
  List<Donacion> obtenerTodasLasDonaciones() {
    return List.unmodifiable(_donacionesMock);
  }

  // Método auxiliar para obtener donaciones de un usuario (útil para insignias)
  List<Donacion> obtenerDonacionesPorUsuario(int usuarioId) {
    return _donacionesMock.where((d) => d.usuarioId == usuarioId).toList();
  }

  // Método auxiliar para obtener el total donado por un usuario
  double obtenerTotalDonadoPorUsuario(int usuarioId) {
    return _donacionesMock
        .where((d) => d.usuarioId == usuarioId)
        .fold(0.0, (total, d) => total + d.monto);
  }

  // Método auxiliar para contar donaciones de un usuario (útil para insignias)
  int contarDonacionesDeUsuario(int usuarioId) {
    return _donacionesMock.where((d) => d.usuarioId == usuarioId).length;
  }
}