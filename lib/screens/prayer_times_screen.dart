import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // ✅ TAMBAHKAN INI
import '../config/theme.dart';
import '../services/prayer_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'quran_list_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  int _currentIndex = 1;
  final PrayerService _prayerService = PrayerService();

  Map<String, String> prayerTimes = {};
  String selectedCity = '';
  String gregorianDate = '';
  String hijriDate = '';
  String nextPrayerName = '';
  String nextPrayerTime = '';
  String nextPrayerRemaining = '';
  bool _isLoading = true;

  // ✅ TAMBAHKAN TIMER
  Timer? _countdownTimer;
  Duration _remainingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
    _startCountdownTimer(); // ✅ START TIMER
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // ✅ CANCEL TIMER
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final settings = context.watch<SettingsProvider>();
    if (selectedCity.isNotEmpty && selectedCity != settings.selectedCity) {
      print('🔄 City changed to ${settings.selectedCity}, reloading...');
      _loadPrayerData();
    }
  }

  // ✅ TIMER UNTUK UPDATE SETIAP DETIK
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemainingTime();
        });
      }
    });
  }

  // ✅ HITUNG WAKTU TERSISA
  void _calculateRemainingTime() {
    if (nextPrayerTime.isEmpty || prayerTimes.isEmpty) {
      _remainingDuration = Duration.zero;
      return;
    }

    try {
      final now = DateTime.now();
      
      // Parse next prayer time
      final timeParts = nextPrayerTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      var nextPrayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      
      // Jika waktu sudah lewat, berarti besok
      if (nextPrayerDateTime.isBefore(now)) {
        nextPrayerDateTime = nextPrayerDateTime.add(const Duration(days: 1));
      }
      
      _remainingDuration = nextPrayerDateTime.difference(now);
      
      // Jika negatif, set ke 0
      if (_remainingDuration.isNegative) {
        _remainingDuration = Duration.zero;
      }
    } catch (e) {
      print('Error calculating remaining time: $e');
      _remainingDuration = Duration.zero;
    }
  }

  // ✅ FORMAT COUNTDOWN JAM:MENIT:DETIK
  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadPrayerData() async {
    setState(() => _isLoading = true);

    try {
      final settings = context.read<SettingsProvider>();
      
      await _prayerService.refreshPrayerTimes(
        city: settings.selectedCity,
        country: 'Indonesia',
      );
      
      prayerTimes = await _prayerService.getPrayerTimesMap();
      selectedCity = await _prayerService.getCity();

      final dates = await _prayerService.getDates();
      gregorianDate = dates['gregorian'] ?? '';
      hijriDate = dates['hijri'] ?? '';

      final nextPrayer = await _prayerService.getNextPrayer();
      nextPrayerName = nextPrayer['name'] ?? '';
      nextPrayerTime = nextPrayer['time'] ?? '';
      nextPrayerRemaining = nextPrayer['remaining'] ?? '';

      // ✅ HITUNG COUNTDOWN AWAL
      _calculateRemainingTime();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading prayer data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        final settings = context.read<SettingsProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settings.getText(
                'Gagal memuat jadwal sholat: $e',
                'Failed to load prayer times: $e',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      return const DashboardScreen();
    } else if (_currentIndex == 2) {
      return const ProfileScreen();
    } else if (_currentIndex == 3) {
      return const SettingsScreen();
    } else if (_currentIndex == 4) {
      return const QuranListScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadPrayerData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildPrayerTimesList(),
                      const SizedBox(height: 20),
                      _buildDateInfo(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    final settings = context.watch<SettingsProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mosque,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            settings.prayerTimes,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                selectedCity,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            gregorianDate,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: prayerTimes.entries.map((entry) {
          final isLast = entry.key == prayerTimes.keys.last;
          final isNext = entry.key == nextPrayerName;

          return _buildPrayerTimeItem(
            entry.key,
            entry.value,
            isLast: isLast,
            isNext: isNext,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrayerTimeItem(
    String name,
    String time, {
    bool isLast = false,
    bool isNext = false,
  }) {
    final settings = context.watch<SettingsProvider>();

    String translatedName = name;
    switch (name) {
      case 'Subuh':
        translatedName = settings.subuh;
        break;
      case 'Terbit':
        translatedName = settings.terbit;
        break;
      case 'Dhuha':
        translatedName = settings.dhuha;
        break;
      case 'Dzuhur':
        translatedName = settings.dzuhur;
        break;
      case 'Ashar':
        translatedName = settings.ashar;
        break;
      case 'Maghrib':
        translatedName = settings.maghrib;
        break;
      case 'Isya':
        translatedName = settings.isya;
        break;
    }

    IconData icon;
    switch (name) {
      case 'Subuh':
      case 'Terbit':
      case 'Dhuha':
        icon = Icons.wb_twilight;
        break;
      case 'Dzuhur':
        icon = Icons.wb_sunny;
        break;
      case 'Ashar':
        icon = Icons.wb_cloudy;
        break;
      case 'Maghrib':
        icon = Icons.brightness_3;
        break;
      case 'Isya':
        icon = Icons.nights_stay;
        break;
      default:
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryPink.withOpacity(0.1)
            : Colors.transparent,
        border: !isLast
            ? const Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              )
            : null,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNext
                      ? AppColors.primaryPink.withOpacity(0.2)
                      : AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      isNext ? AppColors.primaryPink : AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  translatedName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    color: isNext ? AppColors.primaryPink : AppColors.textDark,
                  ),
                ),
              ),

              Text(
                time,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      isNext ? AppColors.primaryPink : AppColors.primaryPurple,
                ),
              ),
            ],
          ),

          // ✅ COUNTDOWN REAL-TIME JAM:MENIT:DETIK
          if (isNext && _remainingDuration.inSeconds > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPink.withOpacity(0.15),
                    AppColors.primaryPink.withOpacity(0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 24,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatCountdown(_remainingDuration),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPink,
                      letterSpacing: 2,
                      fontFeatures: [
                        FontFeature.tabularFigures(), // Monospace numbers
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    final settings = context.watch<SettingsProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.hijriDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hijriDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}