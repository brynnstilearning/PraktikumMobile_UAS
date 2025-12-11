import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/constants.dart';
import '../models/user_model.dart';

// STORAGE SERVICE
// Service untuk menyimpan data ke SharedPreferences

class StorageService {
  late SharedPreferences _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // USER SESSION
  // Save user session (saat login)
  Future<bool> saveUserSession(User user) async {
    try {
      await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await _prefs.setString(AppConstants.keyCurrentUser, jsonEncode(user.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user session
  User? getCurrentUser() {
    try {
      final userJson = _prefs.getString(AppConstants.keyCurrentUser);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user logged in
  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Logout (clear session)
  Future<bool> logout() async {
    try {
      await _prefs.remove(AppConstants.keyIsLoggedIn);
      await _prefs.remove(AppConstants.keyCurrentUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  // REGISTERED USERS (dari register)
  // Get all registered users
  List<User> getRegisteredUsers() {
    try {
      final usersJson = _prefs.getString(AppConstants.keyRegisteredUsers);
      if (usersJson != null) {
        List<dynamic> jsonList = jsonDecode(usersJson);
        return jsonList.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Save registered users
  Future<bool> saveRegisteredUsers(List<User> users) async {
    try {
      List<Map<String, dynamic>> jsonList = users.map((user) => user.toJson()).toList();
      await _prefs.setString(AppConstants.keyRegisteredUsers, jsonEncode(jsonList));
      return true;
    } catch (e) {
      return false;
    }
  }

  // THEME MODE
  // Get theme mode (light/dark/system)
  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'light';
  }

  // Save theme mode
  Future<bool> saveThemeMode(String mode) async {
    try {
      await _prefs.setString(AppConstants.keyThemeMode, mode);
      return true;
    } catch (e) {
      return false;
    }
  }

  // LANGUAGE
  // Get language
  String getLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'id';
  }

  // Save language
  Future<bool> saveLanguage(String language) async {
    try {
      await _prefs.setString(AppConstants.keyLanguage, language);
      return true;
    } catch (e) {
      return false;
    }
  }

  // SELECTED CITY (untuk prayer times)
  // Get selected city
  String getSelectedCity() {
    return _prefs.getString(AppConstants.keySelectedCity) ?? AppConstants.defaultCity;
  }

  // Save selected city
  Future<bool> saveSelectedCity(String city) async {
    try {
      await _prefs.setString(AppConstants.keySelectedCity, city);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CLEAR ALL DATA (untuk debugging atau logout total)
  Future<bool> clearAll() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}