import 'package:flutter/material.dart';
import 'package:jadwal_kajian_new/providers/settings_provider.dart';
import 'package:jadwal_kajian_new/services/kajian_service.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'prayer_times_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'quran_list_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2;
  
  // ✅ TAMBAHKAN VARIABEL UNTUK STATS
  final KajianService _kajianService = KajianService();
  int _totalKajian = 0;
  int _thisMonthKajian = 0;
  bool _isLoadingStats = true;

  // ✅ LOAD STATS SAAT INIT
  @override
  void initState() {
    super.initState();
    _loadKajianStats();
  }

  // ✅ FUNGSI UNTUK LOAD STATS DARI FIREBASE
  Future<void> _loadKajianStats() async {
    setState(() => _isLoadingStats = true);

    try {
      // Load semua kajian
      final allKajian = await _kajianService.loadKajian();
      
      // Hitung total
      final total = allKajian.length;
      
      // Hitung kajian bulan ini
      final now = DateTime.now();
      final thisMonth = allKajian.where((kajian) {
        try {
          final kajianDate = DateTime.parse(kajian.date);
          return kajianDate.year == now.year && kajianDate.month == now.month;
        } catch (e) {
          return false;
        }
      }).length;

      setState(() {
        _totalKajian = total;
        _thisMonthKajian = thisMonth;
        _isLoadingStats = false;
      });

      print('📊 Stats loaded: Total=$total, This Month=$thisMonth');
    } catch (e) {
      print('❌ Error loading stats: $e');
      setState(() {
        _totalKajian = 0;
        _thisMonthKajian = 0;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 0) {
      return const DashboardScreen();
    } else if (_currentIndex == 1) {
      return const PrayerTimesScreen();
    } else if (_currentIndex == 3) {
      return const SettingsScreen();
    } else if (_currentIndex == 4) {
      return const QuranListScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.currentUser;
            final settings = context.watch<SettingsProvider>();

            if (user == null) {
              return Center(
                child: Text(settings.getText('User tidak ditemukan', 'User not found')),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadKajianStats, // ✅ REFRESH STATS
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(user.name, user.email, user.phoneNumber),
                    const SizedBox(height: 20),
                    _buildStatsCards(), // ✅ STATS CARDS DENGAN DATA REAL
                    const SizedBox(height: 20),
                    _buildMenuSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
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

  Widget _buildHeader(String name, String email, String phoneNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPink,
            AppColors.primaryPink.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (name.isNotEmpty) ? name.substring(0, 1).toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name.isNotEmpty ? name : 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    email.isNotEmpty ? email : 'email@example.com',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

  // ✅ UPDATE STATS CARDS DENGAN DATA REAL
  Widget _buildStatsCards() {
    final settings = context.watch<SettingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.event,
              label: settings.totalKajian,
              value: _isLoadingStats ? '...' : '$_totalKajian',
              color: AppColors.primaryPurple,
              isLoading: _isLoadingStats,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_month,
              label: settings.thisMonth,
              value: _isLoadingStats ? '...' : '$_thisMonthKajian',
              color: AppColors.accentGreen,
              isLoading: _isLoadingStats,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATE STAT CARD DENGAN LOADING STATE
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          
          // ✅ TAMPILKAN LOADING ATAU VALUE
          isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
          
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final settings = context.watch<SettingsProvider>();

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
        children: [
          _buildMenuItem(
            icon: Icons.person,
            title: settings.editProfileTitle,
            subtitle: settings.getText('Ubah nama dan nomor telepon', 'Change name and phone number'),
            onTap: () async {
              // ✅ REFRESH STATS SETELAH EDIT PROFILE
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              
              // Tidak perlu reload stats karena edit profile tidak mengubah kajian
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.lock,
            title: settings.changePasswordTitle,
            subtitle: settings.getText('Ubah password akun', 'Change account password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.logout,
            title: settings.logout,
            subtitle: settings.getText('Keluar dari akun', 'Sign out from account'),
            iconColor: Colors.red,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryPink).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryPink,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
  }

  void _showLogoutDialog() {
    final settings = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.logout),
        content: Text(settings.getText(
          'Apakah Anda yakin ingin keluar?',
          'Are you sure you want to sign out?',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(settings.logout),
          ),
        ],
      ),
    );
  }
}