import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/crop.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado principal
  UserProfile _userProfile = UserProfile.defaultProfile();
  bool _isLoading = false;
  String _selectedCropId = 'corn';

  // Getters
  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get selectedCropId => _selectedCropId;

  // Cultivos disponibles
  List<Crop> get availableCrops => [
    Crop(id: 'corn', name: 'Maíz', icon: '🌽', isSelected: _selectedCropId == 'corn'),
    Crop(id: 'potato', name: 'Papa', icon: '🥔', isSelected: _selectedCropId == 'potato'),
    Crop(id: 'quinoa', name: 'Quinua', icon: '🌾', isSelected: _selectedCropId == 'quinoa'),
    Crop(id: 'bean', name: 'Fréjol', icon: '🫘', isSelected: _selectedCropId == 'bean'),
    Crop(id: 'barley', name: 'Cebada', icon: '🌿', isSelected: _selectedCropId == 'barley'),
    Crop(id: 'other', name: 'Otros', icon: '🥕', isSelected: _selectedCropId == 'other'),
  ];

  // Configuraciones de notificaciones
  Map<String, bool> _notificationSettings = {
    'weather_alerts': true,
    'fertilization_reminders': true,
    'weekly_tips': false,
    'pest_alerts': true,
  };

  Map<String, bool> get notificationSettings => _notificationSettings;

  // Métodos para actualizar perfil
  void selectCrop(String cropId) {
    _selectedCropId = cropId;
    _userProfile = _userProfile.copyWith(primaryCrop: cropId);
    notifyListeners();
  }

  void updateFarmSize(String size) {
    _userProfile = _userProfile.copyWith(farmSize: size);
    notifyListeners();
  }

  void updateSoilType(String soilType) {
    _userProfile = _userProfile.copyWith(soilType: soilType);
    notifyListeners();
  }

  void updateLocation(String location, double latitude, double longitude, int altitude) {
    _userProfile = _userProfile.copyWith(
      location: location,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
    );
    notifyListeners();
  }

  void updateNotificationSetting(String key, bool value) {
    _notificationSettings[key] = value;
    notifyListeners();
  }

  void updateLanguage(String language) {
    _userProfile = _userProfile.copyWith(language: language);
    notifyListeners();
  }

  String get selectedCropName =>
      availableCrops.firstWhere((crop) => crop.id == _selectedCropId).name;

  String get selectedCropIcon =>
      availableCrops.firstWhere((crop) => crop.id == _selectedCropId).icon;

  // Guardar perfil (simulación de API/local storage)
  Future<void> saveProfile() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Aquí se guardaría en Firestore o almacenamiento local
    _isLoading = false;
    notifyListeners();
  }

  // Cargar perfil desde Firebase o almacenamiento
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      _userProfile = UserProfile(
        name: user.displayName ?? user.email?.split('@').first ?? 'Usuario',
        primaryCrop: _selectedCropId,
        location: 'Cotopaxi, Ecuador',
        latitude: -0.9324,
        longitude: -78.6156,
        altitude: 2800,
        farmSize: '2.5 hectáreas',
        soilType: 'Franco arcilloso',
        language: 'Español',
      );
    } else {
      _userProfile = UserProfile.defaultProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Estadísticas
  int get totalQueries => 47;
  int get daysUsing => 12;
  double get averageQueriesPerDay => totalQueries / daysUsing;
}
