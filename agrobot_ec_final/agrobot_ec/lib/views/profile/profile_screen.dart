import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/profile/crop_selector.dart';
import '../../widgets/profile/location_picker.dart';
import '../../widgets/profile/stats_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _farmSizeController = TextEditingController();
  String _selectedSoilType = 'Franco arcilloso';
  String _selectedLanguage = 'Español';

  final List<String> _soilTypes = [
    'Franco arcilloso',
    'Franco arenoso',
    'Arcilloso',
    'Arenoso',
  ];

  final List<String> _languages = [
    'Español',
    'Kichwa',
    'Español + Kichwa',
  ];

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ProfileViewModel>();
    _farmSizeController.text = viewModel.userProfile.farmSize;
    _selectedSoilType = viewModel.userProfile.soilType;
    _selectedLanguage = viewModel.userProfile.language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadProfile();
    });
  }

  @override
  void dispose() {
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text(
                      '👨‍🌾',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  viewModel.userProfile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 30),

                // Crop Selector
                _buildSection(
                  title: '🌱 Cultivo Principal',
                  child: CropSelector(
                    crops: viewModel.availableCrops,
                    onCropSelected: viewModel.selectCrop,
                  ),
                ),

                // Farm Info
                _buildSection(
                  title: '🚜 Información de la Finca',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _farmSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Extensión del cultivo',
                          hintText: '2.5 hectáreas',
                        ),
                        onChanged: viewModel.updateFarmSize,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedSoilType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de suelo',
                        ),
                        items: _soilTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSoilType = value);
                            viewModel.updateSoilType(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Location
                _buildSection(
                  title: '📍 Ubicación',
                  child: LocationPicker(
                    currentLocation: viewModel.userProfile.location,
                    latitude: viewModel.userProfile.latitude,
                    longitude: viewModel.userProfile.longitude,
                    altitude: viewModel.userProfile.altitude,
                    onLocationChanged: viewModel.updateLocation,
                  ),
                ),

                // Statistics
                _buildSection(
                  title: '📊 Estadísticas',
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          value: viewModel.totalQueries.toString(),
                          label: 'Consultas realizadas',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: StatsCard(
                          value: viewModel.daysUsing.toString(),
                          label: 'Días usando la app',
                        ),
                      ),
                    ],
                  ),
                ),

                // Notifications
                _buildSection(
                  title: '🔔 Configuración de Notificaciones',
                  child: Column(
                    children: viewModel.notificationSettings.entries.map((entry) {
                      return _buildNotificationToggle(
                        title: _getNotificationTitle(entry.key),
                        value: entry.value,
                        onChanged: (value) => viewModel.updateNotificationSetting(entry.key, value),
                      );
                    }).toList(),
                  ),
                ),

                // Language
                _buildSection(
                  title: '🌐 Idioma',
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Idioma preferido',
                    ),
                    items: _languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                        viewModel.updateLanguage(value);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      await viewModel.saveProfile();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Perfil guardado correctamente'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      '💾 Guardar Cambios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  String _getNotificationTitle(String key) {
    switch (key) {
      case 'weather_alerts':
        return 'Alertas climáticas';
      case 'fertilization_reminders':
        return 'Recordatorios de fertilización';
      case 'weekly_tips':
        return 'Consejos semanales';
      case 'pest_alerts':
        return 'Alertas de plagas';
      default:
        return key;
    }
  }
}
