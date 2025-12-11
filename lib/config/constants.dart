
class AppConstants {
  static const String appName = 'Kajian Scheduler';
  static const String appVersion = '1.0.0';

  // DEFAULT SETTINGS
  static const String defaultCity = 'Malang';
  static const String defaultCountry = 'Indonesia';
  
  // Available cities in Indonesia (untuk settings)
  static const List<String> indonesiaCities = [
    'Jakarta',
    'Surabaya',
    'Bandung',
    'Medan',
    'Semarang',
    'Makassar',
    'Palembang',
    'Tangerang',
    'Malang',
    'Depok',
    'Yogyakarta',
    'Bogor',
    'Bekasi',
  ];
  
  // SHARED PREFERENCES KEYS
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyCurrentUser = 'current_user';
  static const String keyRegisteredUsers = 'registered_users';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keySelectedCity = 'selected_city';
  
  // PRAYER TIMES (untuk display)
  static const List<String> prayerNames = [
    'Subuh',
    'Dzuhur',
    'Ashar',
    'Maghrib',
    'Isya',
  ];
  
  // Untuk time picker "Ba'da Sholat" (mapping dari prayer_times.json)
  static const List<String> badaSholatOptions = [
    'Ba\'da Subuh',
    'Ba\'da Dzuhur',
    'Ba\'da Ashar',
    'Ba\'da Maghrib',
    'Ba\'da Isya',
  ];
  
  // KAJIAN CATEGORIES
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Tafsir', 'color': 0xFFFFD93D, 'icon': '📖'},
    {'name': 'Hadits', 'color': 0xFF7C6FE8, 'icon': '📚'},
    {'name': 'Fiqih', 'color': 0xFFE94C6F, 'icon': '⚖️'},
    {'name': 'Akhlaq', 'color': 0xFF6BCB77, 'icon': '💚'},
    {'name': 'Sejarah', 'color': 0xFF4ECDC4, 'icon': '🕌'},
    {'name': 'Lainnya', 'color': 0xFF95A5A6, 'icon': '📝'},
  ];
  
  // LANGUAGES
  static const List<Map<String, String>> languages = [
    {'code': 'id', 'name': 'Indonesia', 'flag': '🇮🇩'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
  ];
  
  // ERROR MESSAGES
  static const String errorNoInternet = 'Tidak ada koneksi internet';
  static const String errorServerError = 'Terjadi kesalahan pada server';
  static const String errorUnknown = 'Terjadi kesalahan tidak diketahui';
  static const String errorLoadingData = 'Gagal memuat data';
  
  // JSON FILE PATHS (data dummy)
  static const String kajianJsonPath = 'assets/data/kajian.json';
  static const String prayerTimesJsonPath = 'assets/data/prayer_times.json';
  static const String usersJsonPath = 'assets/data/users.json';
  static const String suratListJsonPath = 'assets/data/surat_list.json';
}