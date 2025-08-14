import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/feed_item.dart';
import '../../widgets/feed/feed_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    // Lista de datos de ejemplo para el feed
    final List<FeedItem> feedItems = [
      FeedItem(
        id: '1',
        title: 'Consejo: Cómo optimizar el riego',
        description: 'Aprende a usar sistemas de riego por goteo para conservar agua y mejorar tus cultivos.',
        category: 'Riego',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FeedItem(
        id: '2',
        title: 'Alerta: Propagación de plaga',
        description: 'Se ha detectado la presencia de la plaga "Gusano Cogollero" en la región de Cotopaxi. Consulta nuestro chat para obtener soluciones.',
        category: 'Plagas',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FeedItem(
        id: '3',
        title: 'Novedad: Nuevo tipo de fertilizante',
        description: 'Descubre los beneficios del nuevo fertilizante orgánico para el cultivo de maíz.',
        category: 'Fertilización',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FeedItem(
        id: '4',
        title: 'Evento: Taller de agricultura sostenible',
        description: 'Únete a nuestro taller en línea para aprender sobre prácticas agrícolas que cuidan el medio ambiente.',
        category: 'Eventos',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroBot EC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(AppRoutes.home + '/${AppRoutes.profile}'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.home + '/${AppRoutes.settings}'),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await Provider.of<AuthViewModel>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensaje de bienvenida
              Text(
                'Hola, ${homeViewModel.userName}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿En qué podemos ayudarte hoy?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 24),

              // Sección de tarjetas de características
              _buildFeatureCards(context),

              const SizedBox(height: 32),

              // Sección del Feed de Noticias
              _buildFeedSection(context, feedItems),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go(AppRoutes.home + '/${AppRoutes.notifications}');
              break;
            case 2:
              context.go(AppRoutes.home + '/${AppRoutes.profile}');
              break;
            case 3:
              context.go(AppRoutes.home + '/${AppRoutes.settings}');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.0,
      children: [
        _buildFeatureCard(
          context,
          title: 'Asistente IA',
          description: 'Chatea con AgroBot para resolver tus dudas agrícolas.',
          icon: Icons.chat_bubble_outline,
          onTap: () => context.go(AppRoutes.home + '/${AppRoutes.chat}'),
        ),
        _buildFeatureCard(
          context,
          title: 'Historial',
          description: 'Consulta tus conversaciones pasadas.',
          icon: Icons.history,
          onTap: () => context.go(AppRoutes.home + '/${AppRoutes.history}'),
        ),
        _buildFeatureCard(
          context,
          title: 'Notificaciones',
          description: 'Recibe alertas sobre el estado de tus cultivos.',
          icon: Icons.notifications_none,
          onTap: () => context.go(AppRoutes.home + '/${AppRoutes.notifications}'),
        ),
        _buildFeatureCard(
          context,
          title: 'Mi Perfil',
          description: 'Administra tu información y preferencias.',
          icon: Icons.person_outline,
          onTap: () => context.go(AppRoutes.home + '/${AppRoutes.profile}'),
        ),
      ],
    );
  }

  // Widget para construir una tarjeta de función sin imagen
  Widget _buildFeatureCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir la sección del feed
  Widget _buildFeedSection(BuildContext context, List<FeedItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feed de Noticias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        // Se utiliza Column en lugar de ListView para evitar conflictos de scroll anidados
        Column(
          children: items.map((item) => FeedCard(item: item)).toList(),
        ),
      ],
    );
  }
}