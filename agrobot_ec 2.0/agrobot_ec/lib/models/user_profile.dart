class UserProfile {
  final String name;
  final String email;

  UserProfile({
    required this.name,
    required this.email,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] ?? 'Usuario',
      email: data['email'] ?? 'N/A',
    );
  }

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Usuario',
      email: 'N/A',
    );
  }
}