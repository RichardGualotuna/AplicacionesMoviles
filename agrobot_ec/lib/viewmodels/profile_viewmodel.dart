import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/crop.dart';

class ProfileViewModel extends ChangeNotifier {
  UserProfile _userProfile = UserProfile.defaultProfile();
  bool _isLoading = false;
  String _selectedCropId = 'corn';

  // Getters
  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get selectedCropId => _selectedCropId;

  // Available crops
  List<Crop> get availableCrops => [
    Crop(id: 'corn', name: 'Maíz', icon: '🌽', isSelected: _selectedCropId == 'corn'),
    Crop(id: 'potato', name: 'Papa', icon: '🥔', isSelected: _selectedCropId == 'potato'),
    Crop(id: 'quinoa', name: 'Quinua', icon: '🌾', isSelected: _selectedCropId == 'quinoa'),
    Crop(id: 'bean', name: 'Fréjol', icon: '🫘', isSelected: _selectedCropId == 'bean'),
    Crop(id: 'barley', name: 'Cebada', icon: '🌿', isSelected: _selectedCropId == 'barley'),
    Crop(id: 'other', name: 'Otros', icon: '🥕', isSelected: _selectedCropId == 'other'),
  ];

  // Notification settings
  Map<String, bool> _notificationSettings = {
    'weather_alerts': true,
    'fertilization_reminders': true,
    'weekly_tips': false,
    'pest_alerts': true,
  };

  Map<String, bool> get notificationSettings => _notificationSettings;

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

  String get selectedCropName {
    return availableCrops.firstWhere((crop) => crop.id == _selectedCropId).name;
  }

  String get selectedCropIcon {
    return availableCrops.firstWhere((crop) => crop.id == _selectedCropId).icon;
  }

  Future<void> saveProfile() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Here you would typically save to local storage or API
    
    _isLoading = false;
    notifyListeners();
  }

  void loadProfile() {
    // Load from local storage or API
    // For now, we use default values
    _userProfile = UserProfile.defaultProfile();
    notifyListeners();
  }

  // Statistics
  int get totalQueries => 47;
  int get daysUsing => 12;
  double get averageQueriesPerDay => totalQueries / daysUsing;
}