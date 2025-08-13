import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/history/history_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/auth/login_screen.dart'; // 🔹 Importa la pantalla de login
import '../viewmodels/auth_viewmodel.dart'; // 🔹 Importa el AuthViewModel

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login'; // 🔹 Nueva ruta
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String settings = '/settings';

  static final AuthViewModel authViewModel = AuthViewModel();

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: authViewModel, // 🔹 Escucha los cambios del estado de auth
    redirect: (context, state) {
      final loggedIn = authViewModel.isLoggedIn;
      final loggingIn = state.matchedLocation == login;

      // Si el usuario no ha iniciado sesión, redirigir a la pantalla de login.
      if (!loggedIn && !loggingIn) return login;

      // Si el usuario ya ha iniciado sesión, redirigir de vuelta a la página principal.
      if (loggedIn && loggingIn) return chat;

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login, // 🔹 Agrega la ruta de login
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}