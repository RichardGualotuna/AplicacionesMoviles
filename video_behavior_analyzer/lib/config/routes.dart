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
      page: () => const HomeView(),
    ),
    GetPage(
      name: camera,
      page: () => const CameraView(),
    ),
    GetPage(
      name: analysisResults,
      page: () => const AnalysisResultsView(),
    ),
    GetPage(
      name: videoPlayer,
      page: () => const VideoPlayerView(),
    ),
  ];
}