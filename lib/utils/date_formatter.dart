import 'package:intl/intl.dart';

// DATE FORMATTER
// Helper untuk format tanggal

class DateFormatter {

  // Format tanggal Indonesia (7 Oktober 2025)
  static String formatIndonesian(DateTime date) {
    final months = [
      '', // index 0 tidak dipakai
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // Format tanggal pendek (7 Okt 2025)
  static String formatShort(DateTime date) {
    final months = [
      '', // index 0 tidak dipakai
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // Format hari dan tanggal (Senin, 7 Oktober 2025)
  static String formatWithDay(DateTime date) {
    final days = [
      '', // index 0 tidak dipakai
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    
    final months = [
      '', // index 0 tidak dipakai
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    String dayName = days[date.weekday];
    return '$dayName, ${date.day} ${months[date.month]} ${date.year}';
  }

  // Format waktu (14:30)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Parse dari string ISO (2025-10-07) ke DateTime
  static DateTime? parseIsoDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get greeting berdasarkan waktu
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 11) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Check apakah tanggal hari ini
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // Check apakah tanggal besok
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  // Get relative date (Hari ini, Besok, atau tanggal)
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Hari ini';
    } else if (isTomorrow(date)) {
      return 'Besok';
    } else {
      return formatIndonesian(date);
    }
  }
}