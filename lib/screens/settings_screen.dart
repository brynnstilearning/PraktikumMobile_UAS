import 'package:flutter/material.dart';
import 'package:jadwal_kajian_new/services/prayer_service.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'prayer_times_screen.dart';
import 'profile_screen.dart';
import 'quran_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      return const DashboardScreen();
    } else if (_currentIndex == 1) {
      return const PrayerTimesScreen();
    } else if (_currentIndex == 2) {
      return const ProfileScreen();
    } else if (_currentIndex == 4) {
      return const QuranListScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              // Appearance Section
              _buildSection(
                title: context.watch<SettingsProvider>().appearance,
                children: [
                  _buildThemeSetting(),
                ],
              ),

              const SizedBox(height: 20),

              // Language Section
              _buildSection(
                title: context.watch<SettingsProvider>().language_label,
                children: [
                  _buildLanguageSetting(),
                ],
              ),

              const SizedBox(height: 20),

              // Location Section
              _buildSection(
                title: context.watch<SettingsProvider>().location,
                children: [
                  _buildCitySetting(),
                ],
              ),

              const SizedBox(height: 20),

              // ❌ HAPUS SELURUH NOTIFICATION SECTION INI:
              /*
              _buildSection(
                title: context
                    .watch<SettingsProvider>()
                    .getText('Notifikasi', 'Notifications'),
                children: [
                  _buildNotificationSetting(),
                ],
              ),

              const SizedBox(height: 20),
              */

              // About Section
              _buildSection(
                title: context
                    .watch<SettingsProvider>()
                    .getText('Tentang', 'About'),
                children: [
                  _buildAboutSetting(),
                ],
              ),

              const SizedBox(height: 100),
            ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.settings,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            settings.settings,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settings.customizeApp,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSetting() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.darkMode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.isDarkMode ? settings.active : settings.inactive,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.toggleTheme();
                },
                activeColor: AppColors.primaryPurple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSetting() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return InkWell(
          onTap: () {
            _showLanguageDialog(settings);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppColors.accentBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.language_label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.language == 'id' ? 'Indonesia' : 'English',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.languages.map((lang) {
            return RadioListTile<String>(
              title: Row(
                children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(lang['name']!),
                ],
              ),
              value: lang['code']!,
              groupValue: settings.language,
              activeColor: AppColors.primaryPink,
              onChanged: (value) {
                if (value != null) {
                  settings.changeLanguage(value);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${settings.languageChanged} ${lang['name']}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.close),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySetting() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return InkWell(
          onTap: () {
            _showCityDialog(settings);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: AppColors.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.city,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.selectedCity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCityDialog(SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.chooseCity),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.indonesiaCities.length,
            itemBuilder: (context, index) {
              final city = AppConstants.indonesiaCities[index];

              return RadioListTile<String>(
                title: Text(city),
                value: city,
                groupValue: settings.selectedCity,
                activeColor: AppColors.primaryPink,
                onChanged: (value) async {
                  if (value != null) {
                    await PrayerService().refreshPrayerTimes(
                      city: value,
                      country: 'Indonesia',
                    );

                    await settings.changeCity(value);

                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${settings.cityChanged} $value'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.close),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSetting() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return InkWell(
          onTap: () {
            _showAboutDialog(settings);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryPink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.aboutApp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${settings.version} 1.0.0',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mosque,
                color: AppColors.primaryPink,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(settings.aboutApp),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kajian Scheduler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${settings.version} 1.0.0'),
            const SizedBox(height: 16),
            Text(
              settings.getText(
                'Aplikasi untuk mengatur jadwal kajian Islami Anda.',
                'App to manage your Islamic study schedule.',
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              settings.getText(
                '© 2025 Kajian Scheduler\nDibuat untuk Project Mobile Programming',
                '© 2025 Kajian Scheduler\nCreated for Mobile Programming Project',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.close),
          ),
        ],
      ),
    );
  }

  // ❌ HAPUS FUNGSI _buildNotificationSetting() SEPENUHNYA
}