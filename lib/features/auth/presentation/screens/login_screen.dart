import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/login_form.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is AuthSuccess) {
          context.go('/home');
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },

      child: Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: LoginForm(),
        ),
      ),
    );
  }
}