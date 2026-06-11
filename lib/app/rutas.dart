import 'package:go_router/go_router.dart';

import '../componentes/splash/splash_screen.dart';
import '../componentes/welcome/welcome_screen.dart';
import '../componentes/auth/login_screen.dart';
import '../componentes/auth/registro_screen.dart';
import '../componentes/auth/password_screen.dart';
import '../componentes/home/home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistroScreen(),
    ),
    GoRoute(
      path: '/password',
      builder: (context, state) => const PasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);