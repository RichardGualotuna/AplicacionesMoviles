import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String _language = 'Español';
  String _theme = 'Claro';
  bool _pushNotifications = true;
  String _notificationFrequency = 'Diaria';
  bool _voiceEnabled = true;
  bool _locationEnabled = true;

  // Getters
  String get language => _language;
  String get theme => _theme;
  bool get pushNotifications => _pushNotifications;
  String get notificationFrequency => _notificationFrequency;
  bool get voiceEnabled => _voiceEnabled;
  bool get locationEnabled => _locationEnabled;

  // Available options
  List<String> get availableLanguages => ['Español', 'Kichwa', 'Español + Kichwa'];
  List<String> get availableThemes => ['Claro', 'Oscuro', 'Sistema'];
  List<String> get availableFrequencies => ['Diaria', 'Semanal', 'Mensual', 'Nunca'];

  // App info
  String get appVersion => '1.0.0';
  String get buildNumber => '1';
  String get appName => 'AgroBot EC';

  void setLanguage(String newLanguage) {
    _language = newLanguage;
    notifyListeners();
    _saveSettings();
  }

  void setTheme(String newTheme) {
    _theme = newTheme;
    notifyListeners();
    _saveSettings();
  }

  void setPushNotifications(bool enabled) {
    _pushNotifications = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setNotificationFrequency(String frequency) {
    _notificationFrequency = frequency;
    notifyListeners();
    _saveSettings();
  }

  void setVoiceEnabled(bool enabled) {
    _voiceEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setLocationEnabled(bool enabled) {
    _locationEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    // Save to SharedPreferences or Hive
    // Implementation would go here
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> loadSettings() async {
    // Load from SharedPreferences or Hive
    // For now using default values
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _language = 'Español';
    _theme = 'Claro';
    _pushNotifications = true;
    _notificationFrequency = 'Diaria';
    _voiceEnabled = true;
    _locationEnabled = true;
    
    notifyListeners();
    await _saveSettings();
  }

  Future<void> exportData() async {
    // Export user data
    await Future.delayed(const Duration(seconds: 1));
    // Implementation would go here
  }

  Future<void> deleteAccount() async {
    // Delete user account and data
    await Future.delayed(const Duration(seconds: 1));
    // Implementation would go here
  }

  Future<void> clearCache() async {
    // Clear app cache
    await Future.delayed(const Duration(seconds: 1));
    // Implementation would go here
  }

  // Settings sections
  List<SettingsSection> get settingsSections => [
    SettingsSection(
      title: 'Cuenta',
      items: [
        SettingsItem(
          title: 'Editar perfil',
          subtitle: 'Cambiar información personal',
          icon: Icons.person,
          onTap: () {},
        ),
        SettingsItem(
          title: 'Cambiar contraseña',
          subtitle: 'Actualizar credenciales',
          icon: Icons.lock,
          onTap: () {},
        ),
      ],
    ),
    SettingsSection(
      title: 'Notificaciones',
      items: [
        SettingsItem(
          title: 'Alertas push',
          subtitle: pushNotifications ? 'Activadas' : 'Desactivadas',
          icon: Icons.notifications,
          isSwitch: true,
          switchValue: pushNotifications,
          onSwitchChanged: setPushNotifications,
        ),
        SettingsItem(
          title: 'Frecuencia',
          subtitle: notificationFrequency,
          icon: Icons.schedule,
          onTap: () {},
        ),
      ],
    ),
    SettingsSection(
      title: 'General',
      items: [
        SettingsItem(
          title: 'Idioma',
          subtitle: language,
          icon: Icons.language,
          onTap: () {},
        ),
        SettingsItem(
          title: 'Tema',
          subtitle: theme,
          icon: Icons.palette,
          onTap: () {},
        ),
        SettingsItem(
          title: 'Ubicación',
          subtitle: locationEnabled ? 'Habilitada' : 'Deshabilitada',
          icon: Icons.location_on,
          isSwitch: true,
          switchValue: locationEnabled,
          onSwitchChanged: setLocationEnabled,
        ),
      ],
    ),
  ];
}

class SettingsSection {
  final String title;
  final List<SettingsItem> items;

  SettingsSection({required this.title, required this.items});
}

class SettingsItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool? switchValue;
  final Function(bool)? onSwitchChanged;

  SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.isSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
  });
}