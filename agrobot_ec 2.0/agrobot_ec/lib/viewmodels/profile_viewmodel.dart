import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile _userProfile = UserProfile.defaultProfile();
  bool _isLoading = false;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _userProfile = UserProfile.defaultProfile();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _userProfile = UserProfile(
      name: user.displayName ?? user.email?.split('@').first ?? 'Usuario',
      email: user.email ?? 'N/A',
    );

    _isLoading = false;
    notifyListeners();
  }
}