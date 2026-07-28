import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/domain/entities/usuario_publico.dart';
import '../../../auth/domain/usecases/obtener_perfil_publico_usecase.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/avatar_helper.dart';
import '../../../../core/widgets/verificado_badge.dart';

class MiPerfilScreen extends StatefulWidget {
  final int? usuarioId;

  const MiPerfilScreen({super.key, this.usuarioId});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  UsuarioPublico? _perfilPublico;
  bool _cargando = false;
  String? _error;

  bool get _esPerfilPropio => widget.usuarioId == null;

  @override
  void initState() {
    super.initState();
    if (!_esPerfilPropio) {
      _cargarPerfilPublico();
    }
  }

  Future<void> _cargarPerfilPublico() async {
    setState(() => _cargando = true);
    try {
      final useCase = ObtenerPerfilPublicoUseCase(
        context.read<AuthRepositoryImpl>(),
      );
      final perfil = await useCase(widget.usuarioId!);
      setState(() {
        _perfilPublico = perfil;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el perfil';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esPerfilPropio ? "Mi Perfil" : "Perfil"),
        centerTitle: true,
      ),
      body: _esPerfilPropio ? _buildPerfilPropio() : _buildPerfilPublico(),
    );
  }

  Widget _buildPerfilPublico() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final perfil = _perfilPublico;
    if (perfil == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: avatarProvider(perfil.fotoPerfil),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Información personal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Nombre de usuario"),
              subtitle: Text(perfil.nombreUsuario),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Nombre"),
              subtitle: Text('${perfil.nombre} ${perfil.apellidos}'),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Correo"),
              subtitle: Text(perfil.correo),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Teléfono"),
              subtitle: Text(perfil.numTelefono),
            ),
          ),
          if (perfil.verificado) ...[
            const SizedBox(height: 15),
            Card(
              child: ListTile(
                leading: const VerificadoBadge(size: 24),
                title: const Text("Usuario verificado"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerfilPropio() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        Usuario? usuario;

        if (state is AuthSuccess && state.data is Usuario) {
          usuario = state.data as Usuario;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: avatarProvider(usuario?.fotoPerfil),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Información personal",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text("Nombre de usuario"),
                  subtitle: Text(usuario?.nombreUsuario ?? ""),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Nombre"),
                  subtitle: Text(
                    "${usuario?.nombre ?? ''} ${usuario?.apellidos ?? ''}",
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Correo"),
                  subtitle: Text(usuario?.correo ?? ""),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Teléfono"),
                  subtitle: Text(usuario?.numTelefono ?? ""),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text("Fecha de nacimiento"),
                  subtitle: Text(
                    usuario?.fechaNacimiento?.toString().split(' ').first ?? "",
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Insignias",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              const Text(
                "Mis reportes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text("Perrito lesionado"),
                  subtitle: const Text("En proceso"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text("Gatito perdido"),
                  subtitle: const Text("Resuelto"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
