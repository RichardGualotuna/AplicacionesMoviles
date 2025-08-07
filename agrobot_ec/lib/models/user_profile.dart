class UserProfile {
  final String name;
  final String primaryCrop;
  final String location;
  final double latitude;
  final double longitude;
  final int altitude;
  final String farmSize;
  final String soilType;
  final String language;

  UserProfile({
    required this.name,
    required this.primaryCrop,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.farmSize,
    required this.soilType,
    required this.language,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Juan Carlos Pérez',
      primaryCrop: 'corn',
      location: 'Cotopaxi, Ecuador',
      latitude: -0.9324,
      longitude: -78.6156,
      altitude: 2800,
      farmSize: '2.5 hectáreas',
      soilType: 'Franco arcilloso',
      language: 'Español',
    );
  }

  UserProfile copyWith({
    String? name,
    String? primaryCrop,
    String? location,
    double? latitude,
    double? longitude,
    int? altitude,
    String? farmSize,
    String? soilType,
    String? language,
  }) {
    return UserProfile(
      name: name ?? this.name,
      primaryCrop: primaryCrop ?? this.primaryCrop,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      farmSize: farmSize ?? this.farmSize,
      soilType: soilType ?? this.soilType,
      language: language ?? this.language,
    );
  }
}