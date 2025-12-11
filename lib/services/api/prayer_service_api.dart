// lib/services/api/prayer_service_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../interfaces/prayer_service_interface.dart';

class PrayerServiceApi implements PrayerServiceInterface {
  final String baseUrl = 'https://api.aladhan.com/v1';

  // Cache data
  Map<String, dynamic>? _cachedData;
  DateTime? _lastFetch;
  String _currentCity = 'Malang';
  String _currentCountry = 'Indonesia';

  // Cache duration (1 hour)
  final Duration _cacheDuration = const Duration(hours: 1);

  /// Fetch prayer times from API
  Future<Map<String, dynamic>> _fetchPrayerTimes({
    String? city,
    String? country,
  }) async {
    try {
      final cityParam = city ?? _currentCity;
      final countryParam = country ?? _currentCountry;

      // Update current location
      _currentCity = cityParam;
      _currentCountry = countryParam;

      print('🕌 Fetching prayer times for $cityParam, $countryParam...');

      final url = Uri.parse(
          '$baseUrl/timingsByCity/${DateFormat('dd-MM-yyyy').format(DateTime.now())}'
          '?city=$cityParam&country=$countryParam&method=20' // Method 20 = KEMENAG Indonesia
          );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200 && data['status'] == 'OK') {
          _cachedData = data['data'];
          _lastFetch = DateTime.now();

          print('✅ Prayer times fetched successfully');
          return _cachedData!;
        } else {
          throw Exception('API returned error: ${data['status']}');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching prayer times: $e');

      // Return dummy data jika gagal (fallback)
      return _getDummyData();
    }
  }

  /// Get cached or fresh data
  Future<Map<String, dynamic>> _getData() async {
    // Check if cache valid
    if (_cachedData != null && _lastFetch != null) {
      final diff = DateTime.now().difference(_lastFetch!);
      if (diff < _cacheDuration) {
        print('📦 Using cached prayer times');
        return _cachedData!;
      }
    }

    // Fetch new data
    return await _fetchPrayerTimes();
  }

  @override
  Future<Map<String, String>> getPrayerTimesMap() async {
    try {
      final data = await _getData();
      final timings = data['timings'] as Map<String, dynamic>;

      // Extract waktu sholat (format: "04:30 (WIB)" → "04:30")
      return {
        'Subuh': _cleanTime(timings['Fajr']),
        'Terbit': _cleanTime(timings['Sunrise']),
        'Dhuha':
            _cleanTime(timings['Dhuha'] ?? '06:15'), // Dhuha tidak selalu ada
        'Dzuhur': _cleanTime(timings['Dhuhr']),
        'Ashar': _cleanTime(timings['Asr']),
        'Maghrib': _cleanTime(timings['Maghrib']),
        'Isya': _cleanTime(timings['Isha']),
      };
    } catch (e) {
      print('❌ Error getting prayer times map: $e');
      return _getDummyPrayerTimes();
    }
  }

  @override
  Future<Map<String, String>> getNextPrayer() async {
    try {
      final times = await getPrayerTimesMap();
      final now = DateTime.now();

      // List urutan sholat
      final prayers = [
        {'name': 'Subuh', 'time': times['Subuh']!},
        {'name': 'Dzuhur', 'time': times['Dzuhur']!},
        {'name': 'Ashar', 'time': times['Ashar']!},
        {'name': 'Maghrib', 'time': times['Maghrib']!},
        {'name': 'Isya', 'time': times['Isya']!},
      ];

      // Cari sholat berikutnya
      for (var prayer in prayers) {
        final prayerTime = _parseTime(prayer['time']!);
        if (prayerTime.isAfter(now)) {
          final diff = prayerTime.difference(now);
          return {
            'name': prayer['name']!,
            'time': prayer['time']!,
            'remaining': _formatDuration(diff),
          };
        }
      }

      // Jika sudah lewat Isya, next prayer adalah Subuh besok
      final subuhTime = _parseTime(times['Subuh']!);
      final tomorrowSubuh = subuhTime.add(const Duration(days: 1));
      final diff = tomorrowSubuh.difference(now);

      return {
        'name': 'Subuh',
        'time': times['Subuh']!,
        'remaining': _formatDuration(diff),
      };
    } catch (e) {
      print('❌ Error getting next prayer: $e');
      return {
        'name': 'Maghrib',
        'time': '18:00',
        'remaining': '1 jam 30 menit'
      };
    }
  }

  @override
  Future<String> getCity() async {
    return _currentCity;
  }

  @override
  Future<Map<String, String>> getDates() async {
    try {
      final data = await _getData();
      final date = data['date'];

      // Gregorian date
      final gregorian = date['gregorian'];
      final gregDay = gregorian['day'].toString(); // TAMBAHKAN .toString()
      final gregMonthNum =
          int.tryParse(gregorian['month']['number'].toString()) ??
              1; // SAFE PARSING
      final gregMonth = _getIndonesianMonth(gregMonthNum);
      final gregYear = gregorian['year'].toString(); // TAMBAHKAN .toString()
      final gregWeekday =
          _getIndonesianWeekday(gregorian['weekday']['en'].toString());

      // Hijri date
      final hijri = date['hijri'];
      final hijriDay = hijri['day'].toString(); // TAMBAHKAN .toString()
      final hijriMonth =
          hijri['month']['en'].toString(); // TAMBAHKAN .toString()
      final hijriYear = hijri['year'].toString(); // TAMBAHKAN .toString()

      return {
        'gregorian': '$gregWeekday, $gregDay $gregMonth $gregYear',
        'hijri': '$hijriDay $hijriMonth $hijriYear H',
      };
    } catch (e) {
      print('❌ Error getting dates: $e');

      // Fallback: gunakan format manual tanpa intl
      final now = DateTime.now();
      final dayName = _getIndonesianWeekdayFromNumber(now.weekday);
      final monthName = _getIndonesianMonth(now.month);

      return {
        'gregorian': '$dayName, ${now.day} $monthName ${now.year}',
        'hijri': '13 Rabiul Akhir 1447 H',
      };
    }
  }

  @override
  Future<String> getPrayerTimeByName(String prayerName) async {
    try {
      final times = await getPrayerTimesMap();
      final simpleName = prayerName.replaceAll('Ba\'da ', '');
      return times[simpleName] ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<void> refreshPrayerTimes({String? city, String? country}) async {
    await _fetchPrayerTimes(city: city, country: country);
  }

  // === HELPER METHODS ===

  /// Clean time format: "04:30 (WIB)" → "04:30"
  String _cleanTime(String time) {
    return time.split(' ').first;
  }

  /// Parse time string to DateTime (today)
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Format duration to readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours jam $minutes menit';
    } else {
      return '$minutes menit';
    }
  }

  /// Get Indonesian month name
  String _getIndonesianMonth(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month];
  }

  /// Get Indonesian weekday
  String _getIndonesianWeekday(String englishDay) {
    const weekdays = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    return weekdays[englishDay] ?? englishDay;
  }

  /// Dummy data sebagai fallback
  Map<String, dynamic> _getDummyData() {
    return {
      'timings': {
        'Fajr': '04:30',
        'Sunrise': '05:47',
        'Dhuha': '06:15',
        'Dhuhr': '12:00',
        'Asr': '15:15',
        'Maghrib': '18:00',
        'Isha': '19:15',
      },
      'date': {
        'gregorian': {
          'day': DateTime.now().day.toString(),
          'month': {'number': DateTime.now().month.toString()},
          'year': DateTime.now().year.toString(),
          'weekday': {'en': 'Monday'},
        },
        'hijri': {
          'day': '13',
          'month': {'en': 'Rabiul Akhir'},
          'year': '1447',
        }
      }
    };
  }

  Map<String, String> _getDummyPrayerTimes() {
    return {
      'Subuh': '04:30',
      'Terbit': '05:47',
      'Dhuha': '06:15',
      'Dzuhur': '12:00',
      'Ashar': '15:15',
      'Maghrib': '18:00',
      'Isya': '19:15',
    };
  }

  /// Get Indonesian weekday dari nomor (1=Senin, 7=Minggu)
  String _getIndonesianWeekdayFromNumber(int weekday) {
    const weekdays = [
      '', // index 0 tidak dipakai
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return weekdays[weekday];
  }
}
