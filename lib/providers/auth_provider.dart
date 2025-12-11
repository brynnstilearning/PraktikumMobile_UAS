// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Initialize
  Future<void> init() async {
    await _authService.init();

    if (_authService.isLoggedIn()) {
      _currentUser = _authService.getCurrentUser();
      notifyListeners();
    }

    // Listen to auth state changes
    _authService.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _currentUser = result['user'];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // REGISTER
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber, // 👈 TAMBAHKAN INI
      );

      if (result['success']) {
        _currentUser = result['user'];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

// UPDATE PROFILE
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        email: email,
        phoneNumber: phoneNumber, // 👈 TAMBAHKAN INI
      );

      if (result['success']) {
        _currentUser = _authService.getCurrentUser();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // CHANGE PASSWORD
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
