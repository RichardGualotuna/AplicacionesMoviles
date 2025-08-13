import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart'; // 🔹 Importa el nuevo ViewModel de autenticación

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyB2wHt11bL_T5201NGC09x7jDJyScPHbg8",
        authDomain: "cred-e1100.firebaseapp.com",
        projectId: "cred-e1100",
        storageBucket: "cred-e1100.firebasestorage.app",
        messagingSenderId: "985480644544",
        appId: "1:985480644544:web:03ded47b1f8765e97c2a25"
    ),
  );

  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppRoutes.authViewModel), // 🔹 Usa la instancia del AuthViewModel de AppRoutes
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: MaterialApp.router(
        title: 'AgroBot EC',
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}