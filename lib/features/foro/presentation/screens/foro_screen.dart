import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../home/presentation/widgets/bottom_bar.dart';
import '../../../notificaciones/presentation/widgets/campana_badge.dart';
import 'grupos_screen.dart';
import 'adopciones_screen.dart';
import 'mi_organizacion_screen.dart';
import 'publicaciones_screen.dart';
import '../../data/repositories/adopciones_repository.dart';
import '../bloc/adopciones_bloc.dart';
import '../bloc/adopciones_event.dart';

class ForoScreen extends StatelessWidget {
  const ForoScreen({super.key});

  static final AdopcionesRepositoryMemoria _adopcionesRepository =
      AdopcionesRepositoryMemoria();

  bool _esOrganizacion(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    return state is AuthSuccess &&
        state.data is Usuario &&
        (state.data as Usuario).esOrganizacion;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final esOrganizacion = _esOrganizacion(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBody: true,
        backgroundColor: colors.surface,
        appBar: AppBar(
          toolbarHeight: 86,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: colors.surface,
          titleSpacing: 20,
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.pets_rounded,
                  color: colors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Foro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            const Center(child: CampanaBadge()),
            const SizedBox(width: 12),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .55),
                ),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: colors.primary,
                unselectedLabelColor: colors.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: colors.primary, width: 3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 8),
                ),

                tabs: [
                  const Tab(text: 'Publicaciones'),
                  const Tab(text: 'Adopciones'),
                  Tab(text: esOrganizacion ? 'Mi organización' : 'Grupos'),

                ],
              ),
            ),
          ),
        ),
        body: TabBarView(

          children: [
            const PublicacionesScreen(),
            BlocProvider(
              create: (_) => AdopcionesBloc(
                repository: _adopcionesRepository,
              )..add(const AdopcionesSolicitadas()),
              child: const AdopcionesScreen(),
            ),
            esOrganizacion
                ? const MiOrganizacionScreen()
                : const GruposScreen(),
          ],
        ),
        bottomNavigationBar: const BottomBarWidget(currentIndex: 1),
      ),
    );
  }
}
