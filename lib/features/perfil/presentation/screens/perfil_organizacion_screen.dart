import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/organizacion_verificada_badge.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../foro/data/datasources/organizacion_foro_datasource.dart';
import '../../../foro/data/repositories/organizacion_foro_repository_impl.dart';
import '../../../foro/domain/entities/organizacion_foro.dart';
import '../../../foro/presentation/screens/organizacion_perfil_screen.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../../notificaciones/presentation/widgets/campana_badge.dart';
import 'cuenta_bancaria_screen.dart';

class PerfilOrganizacionScreen extends StatefulWidget {
  const PerfilOrganizacionScreen({super.key});

  @override
  State<PerfilOrganizacionScreen> createState() =>
      _PerfilOrganizacionScreenState();
}

class _PerfilOrganizacionScreenState extends State<PerfilOrganizacionScreen> {
  late final Future<OrganizacionForo?> _futureOrg;
  String? _cuenta;
  String? _banco;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final usuarioId = authState is AuthSuccess && authState.data is Usuario
        ? (authState.data as Usuario).usuarioIdPk
        : 0;
    _futureOrg = OrganizacionForoRepositoryImpl(
      OrganizacionForoDataSourceMock(),
    ).obtenerMiOrganizacion(usuarioId);
    _cargarCuenta();
  }

  Future<void> _cargarCuenta() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _cuenta = prefs.getString('org_cuenta');
      _banco = prefs.getString('org_banco');
    });
  }

  String _ocultarCuenta(String digitos) {
    if (digitos.length < 4) return digitos;
    final ultimos4 = digitos.substring(digitos.length - 4);
    return '•••• •••• •••• $ultimos4';
  }

  String _labelCuenta() {
    if (_cuenta == null || _cuenta!.isEmpty) {
      return 'Agrega tu cuenta bancaria';
    }
    final oculta = _ocultarCuenta(_cuenta!);
    if (_banco != null && _banco!.isNotEmpty) {
      return '$_banco $oculta';
    }
    return oculta;
  }

  String _miles(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'N/A';
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${meses[fecha.month - 1]} ${fecha.year}';
  }

  Future<void> _abrirCuenta() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CuentaBancariaScreen()),
    );
    if (resultado == true) _cargarCuenta();
  }

  void _abrirPerfilPublico(OrganizacionForo org) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizacionPerfilScreen(organizacion: org),
      ),
    );
  }

  void _cerrarSesion() {
    context.read<AuthBloc>().add(LogoutEvent());
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Center(child: CampanaBadge()),
          SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<OrganizacionForo?>(
        future: _futureOrg,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final org = snapshot.data;
          if (org == null) {
            return const Center(
              child: Text('No se encontró tu organización.'),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              BottomBarWidget.contentClearance(context) + 16,
            ),
            children: [
              // ===== HEADER DE LA ORGANIZACIÓN =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .45),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: colors.primaryContainer,
                              backgroundImage: org.logoUrl.isNotEmpty
                                  ? NetworkImage(org.logoUrl)
                                  : null,
                              child: org.logoUrl.isEmpty
                                  ? Icon(Icons.pets_rounded,
                                      color: colors.primary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: colors.primary,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => _abrirPerfilPublico(org),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      org.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const OrganizacionVerificadaBadge(size: 18),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Organización',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        org.descripcion,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Stat(
                          icono: Icons.pets_rounded,
                          titulo: 'Rescates',
                          valor: org.cantidadRescates.toString(),
                        ),
                        _Stat(
                          icono: Icons.favorite_rounded,
                          titulo: 'Seguidores',
                          valor: _miles(org.cantidadSeguidores),
                        ),
                        _Stat(
                          icono: Icons.calendar_month,
                          titulo: 'Miembro desde',
                          valor: _formatearFecha(org.fechaRegistro),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // OPCIONES
              _Opcion(
                icono: Icons.account_balance_outlined,
                titulo: 'Mi Cuenta',
                subtitulo: _labelCuenta(),
                onTap: _abrirCuenta,
              ),
              const SizedBox(height: 12),
              _Opcion(
                icono: Icons.shield_outlined,
                titulo: 'Política de privacidad',
                onTap: () => context.push('/privacidad'),
              ),
              const SizedBox(height: 12),
              _Opcion(
                icono: Icons.settings_rounded,
                titulo: 'Configuración',
                onTap: () => context.push('/configuracion'),
              ),
              const SizedBox(height: 12),
              _Opcion(
                icono: Icons.help_outline,
                titulo: 'Ayuda',
                onTap: () => context.push('/ayuda'),
              ),
              const SizedBox(height: 12),
              _Opcion(
                icono: Icons.logout_rounded,
                titulo: 'Cerrar sesión',
                onTap: _cerrarSesion,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomBarWidget(currentIndex: 3),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _Stat({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icono, color: colors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  const _Opcion({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary.withValues(alpha: .15),
                child: Icon(icono, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitulo!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}