// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'config/themes.dart';
import 'controllers/video_controller.dart';
import 'controllers/camera_controller.dart';
import 'controllers/detection_controller.dart';
import 'controllers/storage_controller.dart';
import 'views/home_view.dart';
import 'utils/permissions_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vision Guard',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      home: const HomeView(),
    );
  }
}

class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await PermissionsHelper.requestAllPermissions();
    setState(() {
      _permissionsGranted = granted;
    });

    if (granted) {
      Get.offAll(() => const HomeView());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Permisos Requeridos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'La aplicación necesita permisos de cámara y almacenamiento para funcionar correctamente.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Conceder Permisos'),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeView();
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoController>(() => VideoController());
    Get.lazyPut<CameraControllerX>(() => CameraControllerX());
    Get.lazyPut<DetectionController>(() => DetectionController());
    Get.lazyPut<StorageController>(() => StorageController());
  }
}
