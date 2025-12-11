// lib/services/auth_service.dart

import '../config/service_config.dart';
import '../models/user_model.dart';
import 'interfaces/auth_service_interface.dart';

/// Wrapper class untuk backward compatibility
class AuthService implements AuthServiceInterface {
  final AuthServiceInterface _implementation = ServiceConfig.getAuthService();

  @override
  Future<void> init() {
    return _implementation.init();
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return _implementation.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  }) {
    return _implementation.register(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber, // 👈 TAMBAHKAN INI
    );
  }

  @override
  Future<bool> logout() {
    return _implementation.logout();
  }

  @override
  bool isLoggedIn() {
    return _implementation.isLoggedIn();
  }

  @override
  User? getCurrentUser() {
    return _implementation.getCurrentUser();
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  }) {
    return _implementation.updateProfile(
      userId: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber, // 👈 TAMBAHKAN INI
    );
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _implementation.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Stream<User?> authStateChanges() {
    return _implementation.authStateChanges();
  }
}
