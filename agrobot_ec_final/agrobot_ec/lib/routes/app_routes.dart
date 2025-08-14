import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/home/home_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/history/history_screen.dart';
import '../views/settings/settings_screen.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/notification/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String chat = 'chat';
  static const String profile = 'profile';
  static const String notifications = 'notifications';
  static const String history = 'history';
  static const String settings = 'settings';

  static final AuthViewModel authViewModel = AuthViewModel();

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final loggedIn = authViewModel.isLoggedIn;
      final loggingIn = state.matchedLocation == login;

      // Si el usuario no está logueado y no está en la pantalla de login,
      // redirige a la pantalla de login.
      if (!loggedIn && !loggingIn) {
        return login;
      }

      // Si el usuario está logueado y está en la pantalla de login,
      // redirige a la pantalla de home.
      if (loggedIn && loggingIn) {
        return home;
      }

      // No redirige si el usuario está en el estado correcto (logueado en home, no logueado en login)
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
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
        routes: [
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
          GoRoute(
            path: notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}
