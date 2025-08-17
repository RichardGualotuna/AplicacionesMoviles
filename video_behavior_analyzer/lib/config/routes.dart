// config/routes.dart
import 'package:get/get.dart';
import '../views/home_view.dart';
import '../views/camera_view.dart';
import '../views/analysis_results_view.dart';
import '../views/video_player_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String analysisResults = '/analysis-results';
  static const String videoPlayer = '/video-player';

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () {
        print('Navegando a HOME');
        return const HomeView();
      },
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: camera,
      page: () {
        print('Navegando a CAMERA');
        return const CameraView();
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: analysisResults,
      page: () {
        print('Navegando a ANALYSIS RESULTS');
        return const AnalysisResultsView();
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: videoPlayer,
      page: () {
        print('Navegando a VIDEO PLAYER');
        return const VideoPlayerView();
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}