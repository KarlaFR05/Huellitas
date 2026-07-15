import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: LoginForm(),
      ),
    );
  }
}