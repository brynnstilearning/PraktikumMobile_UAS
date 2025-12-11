// lib/services/interfaces/prayer_service_interface.dart

abstract class PrayerServiceInterface {
  /// Get prayer times as Map<String, String>
  /// Example: {'Subuh': '04:30', 'Dzuhur': '12:00', ...}
  Future<Map<String, String>> getPrayerTimesMap();
  
  /// Get next prayer info
  /// Returns: {'name': 'Maghrib', 'time': '18:00', 'remaining': '2 jam 30 menit'}
  Future<Map<String, String>> getNextPrayer();
  
  /// Get city name
  Future<String> getCity();
  
  /// Get dates (Gregorian & Hijri)
  /// Returns: {'gregorian': '20 Oktober 2025', 'hijri': '13 Rabiul Akhir 1447 H'}
  Future<Map<String, String>> getDates();
  
  /// Get prayer time by name (untuk ba'da sholat)
  /// Example: getPrayerTimeByName('Subuh') → '04:30'
  Future<String> getPrayerTimeByName(String prayerName);
  
  /// Refresh prayer times (fetch dari API)
  Future<void> refreshPrayerTimes({String? city, String? country});
}