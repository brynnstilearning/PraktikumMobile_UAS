// lib/services/interfaces/auth_service_interface.dart

import '../../models/user_model.dart';

abstract class AuthServiceInterface {
  /// Initialize service
  Future<void> init();
  
  /// Login
  Future<Map<String, dynamic>> login(String email, String password);
  
  /// Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber, // 👈 TAMBAHKAN INI (optional)
  });
  
  /// Logout
  Future<bool> logout();
  
  /// Check if user logged in
  bool isLoggedIn();
  
  /// Get current user
  User? getCurrentUser();
  
  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber, // 👈 TAMBAHKAN INI
  });
  
  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  
  /// Stream auth state changes
  Stream<User?> authStateChanges();
}