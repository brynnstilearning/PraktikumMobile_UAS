// lib/config/service_config.dart

import '../services/interfaces/prayer_service_interface.dart';
import '../services/interfaces/quran_service_interface.dart';
import '../services/interfaces/kajian_service_interface.dart';
import '../services/interfaces/auth_service_interface.dart'; // TAMBAHKAN
import '../services/api/prayer_service_api.dart';
import '../services/api/quran_service_api.dart';
import '../services/firebase/kajian_service_firebase.dart';
import '../services/firebase/auth_service_firebase.dart'; // TAMBAHKAN

enum BackendType {
  firebase,
  laravel,
  local,
}

class ServiceConfig {
  static const BackendType currentBackend = BackendType.firebase;
  static const String laravelBaseUrl = 'https://your-api.com/api';
  static const String aladhanApiUrl = 'https://api.aladhan.com/v1';
  static const String quranApiUrl = 'https://api.quran.gading.dev';
  
  static PrayerServiceInterface getPrayerService() {
    return PrayerServiceApi();
  }
  
  static QuranServiceInterface getQuranService() {
    return QuranServiceApi();
  }
  
  static KajianServiceInterface getKajianService() {
    return KajianServiceFirebase();
  }
  
  // === AUTH SERVICE FACTORY === (TAMBAHKAN INI)
  static AuthServiceInterface getAuthService() {
    return AuthServiceFirebase();
  }
}