import 'package:flutter/material.dart';

import '../widgets/password_form.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: PasswordForm(),
      ),
    );
  }
}