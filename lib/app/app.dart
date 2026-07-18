import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'rutas.dart';
import '../core/theme/bloc/theme_bloc.dart';
import '../core/theme/bloc/theme_state.dart';
import '../core/theme/light_theme.dart';
import '../core/theme/dark_theme.dart';

class HuellitasApp extends StatelessWidget {
  const HuellitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,

          theme: lightTheme,
          darkTheme: darkTheme,

          themeMode: state.themeMode,

          routerConfig: router,
        );
      },
    );
  }
}