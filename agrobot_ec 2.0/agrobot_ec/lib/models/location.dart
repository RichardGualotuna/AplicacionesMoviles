class Location {
  final String name;
  final double latitude;
  final double longitude;
  final int altitude;
  final String province;
  final String agroecologicalZone;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.province,
    required this.agroecologicalZone,
  });

  Location copyWith({
    String? name,
    double? latitude,
    double? longitude,
    int? altitude,
    String? province,
    String? agroecologicalZone,
  }) {
    return Location(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      province: province ?? this.province,
      agroecologicalZone: agroecologicalZone ?? this.agroecologicalZone,
    );
  }
}
