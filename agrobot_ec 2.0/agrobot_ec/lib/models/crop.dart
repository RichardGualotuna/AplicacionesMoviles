class Crop {
  final String id;
  final String name;
  final String icon;
  final bool isSelected;

  Crop({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });

  Crop copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isSelected,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}