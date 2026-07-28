import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';

class TemaScreen extends StatelessWidget {
  const TemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tema")),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return RadioGroup<ThemeMode>(
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeBloc>().add(ChangeThemeEvent(value));
              }
            },
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text("Usar tema del sistema"),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text("Claro"),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text("Oscuro"),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
