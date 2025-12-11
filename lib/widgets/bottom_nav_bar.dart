import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>(); // ✅ TAMBAHKAN
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home,
                label: settings.home, // ✅
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.mosque,
                label: settings.getText('Sholat', 'Prayer'), // ✅
                index: 1,
                isActive: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.menu_book,
                label: settings.quran, // ✅
                index: 4,
                isActive: currentIndex == 4,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person,
                label: settings.profile, // ✅
                index: 2,
                isActive: currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.settings,
                label: settings.settings, // ✅
                index: 3,
                isActive: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryPink.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primaryPink
                  : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? AppColors.primaryPink
                    : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}