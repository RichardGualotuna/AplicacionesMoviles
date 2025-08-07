import 'package:go_router/go_router.dart';
import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/profile/profile_screen.dart';
// import '../views/notifications/notifications_screen.dart';
import '../views/history/history_screen.dart';
import '../views/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
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
        path: chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // GoRoute(
      //   path: notifications,
      //   builder: (context, state) => const NotificationScreen(),
      // ),
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