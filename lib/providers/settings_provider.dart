// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'id'; // 'id' atau 'en'
  String _selectedCity = AppConstants.defaultCity;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  String get selectedCity => _selectedCity;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Initialize (load saved settings)
  Future<void> init() async {
    await _storageService.init();
    
    final savedTheme = _storageService.getThemeMode();
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    
    _language = _storageService.getLanguage();
    _selectedCity = _storageService.getSelectedCity();
    
    notifyListeners();
  }

  // Toggle Theme (Light/Dark)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      await _storageService.saveThemeMode('dark');
    } else {
      _themeMode = ThemeMode.light;
      await _storageService.saveThemeMode('light');
    }
    notifyListeners();
  }

  // Set Theme Mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    String modeString;
    if (mode == ThemeMode.dark) {
      modeString = 'dark';
    } else if (mode == ThemeMode.light) {
      modeString = 'light';
    } else {
      modeString = 'system';
    }
    
    await _storageService.saveThemeMode(modeString);
    notifyListeners();
  }

  // Change Language
  Future<void> changeLanguage(String languageCode) async {
    _language = languageCode;
    await _storageService.saveLanguage(languageCode);
    notifyListeners();
  }

  // Change City (untuk prayer times)
  Future<void> changeCity(String city) async {
    _selectedCity = city;
    await _storageService.saveSelectedCity(city);
    notifyListeners();
  }

  // Get localized text (untuk multi-language)
  String getText(String id, String en) {
    return _language == 'id' ? id : en;
  }

  // ========================================
  // TRANSLATIONS - GENERAL
  // ========================================
  String get appName => getText('Kajian Scheduler', 'Islamic Kajian Scheduler');
  String get home => getText('Beranda', 'Home');
  String get profile => getText('Profil', 'Profile');
  String get settings => getText('Pengaturan', 'Settings');
  String get logout => getText('Keluar', 'Logout');
  String get login => getText('Masuk', 'Login');
  String get register => getText('Daftar', 'Register');
  String get email => getText('Email', 'Email');
  String get password => getText('Password', 'Password');
  String get name => getText('Nama', 'Name');
  String get save => getText('Simpan', 'Save');
  String get cancel => getText('Batal', 'Cancel');
  String get edit => getText('Edit', 'Edit');
  String get delete => getText('Hapus', 'Delete');
  String get search => getText('Cari', 'Search');
  String get filter => getText('Filter', 'Filter');
  String get loading => getText('Memuat...', 'Loading...');
  String get refresh => getText('Muat Ulang', 'Refresh');
  
  // ========================================
  // TRANSLATIONS - LOGIN & REGISTER
  // ========================================
  String get welcomeBack => getText('Selamat Datang!', 'Welcome Back!');
  String get loginToContinue => getText('Masuk untuk melanjutkan', 'Login to continue');
  String get enterEmail => getText('Masukkan email Anda', 'Enter your email');
  String get enterPassword => getText('Masukkan password Anda', 'Enter your password');
  String get forgotPassword => getText('Lupa Password?', 'Forgot Password?');
  String get or => getText('atau', 'or');
  String get createNewAccount => getText('Daftar Akun Baru', 'Create New Account');
  String get featureComingSoon => getText('Fitur ini akan segera tersedia', 'This feature will be available soon');
  
  String get registerAccount => getText('Daftar Akun', 'Register Account');
  String get createAccountToContinue => getText('Buat akun baru untuk melanjutkan', 'Create a new account to continue');
  String get fullName => getText('Nama Lengkap', 'Full Name');
  String get enterFullName => getText('Masukkan nama lengkap Anda', 'Enter your full name');
  String get phoneNumber => getText('Nomor Telepon', 'Phone Number');
  String get phoneExample => getText('Contoh: 081234567890', 'Example: 081234567890');
  String get passwordMinimum => getText('Minimal 6 karakter', 'Minimum 6 characters');
  String get confirmPassword => getText('Konfirmasi Password', 'Confirm Password');
  String get enterPasswordAgain => getText('Masukkan password kembali', 'Enter password again');
  String get alreadyHaveAccount => getText('Sudah punya akun? ', 'Already have an account? ');
  String get registerSuccess => getText('Registrasi berhasil! Selamat datang!', 'Registration successful! Welcome!');
  String get registerFailed => getText('Registrasi gagal', 'Registration failed');
  String get loginFailed => getText('Login gagal', 'Login failed');
  
  // ========================================
  // TRANSLATIONS - ADD/EDIT KAJIAN
  // ========================================
  String get addKajianTitle => getText('Tambah Kajian', 'Add Kajian Session');
  String get editKajianTitle => getText('Edit Kajian', 'Edit Kajian Session');
  String get kajianTitle => getText('Judul Kajian', 'Kajian Title');
  String get kajianTitleHint => getText('Contoh: Kajian Tafsir Al-Baqarah', 'Example: Tafsir Al-Baqarah Kajian');
  String get ustadzName => getText('Nama Ustadz', 'Teacher Name');
  String get ustadzNameHint => getText('Contoh: Ustadz Ahmad', 'Example: Ustadz Ahmad');
  String get kajianTheme => getText('Tema Kajian', 'Kajian Theme');
  String get kajianThemeHint => getText('Contoh: Tafsir Al-Quran Juz 1-2', 'Example: Quran Tafsir Juz 1-2');
  String get selectDate => getText('Pilih Tanggal', 'Select Date');
  String get selectTime => getText('Pilih Waktu', 'Select Time');
  String get manual => getText('Manual', 'Manual');
  String get afterPrayer => getText('Ba\'da Sholat', 'After Prayer');
  String get locationLabel => getText('Lokasi', 'Location');
  String get locationHint => getText('Contoh: Masjid Agung Malang', 'Example: Grand Mosque Malang');
  String get notesLabel => getText('Catatan', 'Notes');
  String get notesHint => getText('Catatan tambahan (opsional)', 'Additional notes (optional)');
  String get saveKajian => getText('Simpan Kajian', 'Save Kajian');
  String get kajianStatus => getText('Status Kajian', 'Kajian Status');
  String get upcomingStatus => getText('Akan Datang', 'Upcoming');
  String get pastStatus => getText('Sudah Lewat', 'Past');
  String get editingInfo => getText('Anda sedang mengedit:', 'You are editing:');
  String get deleteConfirm => getText('Apakah Anda yakin ingin menghapus', 'Are you sure you want to delete');
  String get cannotBeUndone => getText('Data yang dihapus tidak dapat dikembalikan.', 'This action cannot be undone.');
  
  // ========================================
  // TRANSLATIONS - EDIT PROFILE
  // ========================================
  String get editProfileTitle => getText('Edit Profil', 'Edit Profile');
  String get updateProfileInfo => getText('Update nama atau nomor telepon Anda.', 'Update your name or phone number.');
  String get emailCannotChange => getText('Email tidak dapat diubah untuk keamanan akun', 'Email cannot be changed for account security');
  String get profileUpdated => getText('Profil berhasil diupdate', 'Profile updated successfully');
  String get noChanges => getText('Tidak ada perubahan data', 'No changes made');
  String get updateFailed => getText('Gagal update profil', 'Failed to update profile');
  
  // ========================================
  // TRANSLATIONS - CHANGE PASSWORD
  // ========================================
  String get changePasswordTitle => getText('Ganti Password', 'Change Password');
  String get passwordSecurityInfo => getText('Pastikan password baru minimal 6 karakter dan mudah diingat.', 'Make sure new password is at least 6 characters and memorable.');
  String get oldPassword => getText('Password Lama', 'Old Password');
  String get enterOldPassword => getText('Masukkan password lama', 'Enter old password');
  String get newPassword => getText('Password Baru', 'New Password');
  String get confirmNewPassword => getText('Konfirmasi Password Baru', 'Confirm New Password');
  String get enterNewPasswordAgain => getText('Masukkan password baru lagi', 'Enter new password again');
  String get changePasswordButton => getText('Ubah Password', 'Change Password');
  String get passwordChanged => getText('Password berhasil diubah', 'Password changed successfully');
  String get passwordChangeFailed => getText('Gagal mengubah password', 'Failed to change password');
  
  // ========================================
  // TRANSLATIONS - DASHBOARD
  // ========================================
  String get addKajian => getText('Tambah Kajian', 'Add Kajian');
  String get all => getText('Semua', 'All');
  String get upcoming => getText('Akan Datang', 'Upcoming');
  String get past => getText('Sudah Lewat', 'Past');
  String get today => getText('Hari Ini', 'Today');
  String get tomorrow => getText('Besok', 'Tomorrow');
  String get noKajian => getText('Belum ada kajian', 'No kajian sessions');
  String get tapToAdd => getText('Tap tombol + untuk menambah kajian', 'Tap + button to add kajian');
  
  // ========================================
  // TRANSLATIONS - PRAYER TIMES
  // ========================================
  String get prayerTimes => getText('Jadwal Sholat', 'Prayer Times');
  String get subuh => getText('Subuh', 'Fajr');
  String get terbit => getText('Terbit', 'Sunrise');
  String get dhuha => getText('Dhuha', 'Dhuha');
  String get dzuhur => getText('Dzuhur', 'Dhuhr');
  String get ashar => getText('Ashar', 'Asr');
  String get maghrib => getText('Maghrib', 'Maghrib');
  String get isya => getText('Isya', 'Isha');
  String get nextPrayer => getText('Sholat Berikutnya', 'Next Prayer');
  String get hijriDate => getText('Tanggal Hijriah', 'Hijri Date');
  
  // ========================================
  // TRANSLATIONS - PROFILE
  // ========================================
  String get changePassword => getText('Ganti Password', 'Change Password');
  String get aboutApp => getText('Tentang Aplikasi', 'About App');
  String get version => getText('Versi', 'Version');
  String get totalKajian => getText('Total Kajian', 'Total Studies');
  String get thisMonth => getText('Bulan Ini', 'This Month');
  
  // ========================================
  // TRANSLATIONS - SETTINGS
  // ========================================
  String get appearance => getText('Tampilan', 'Appearance');
  String get darkMode => getText('Tema Gelap', 'Dark Mode');
  String get lightMode => getText('Mode Terang', 'Light Mode');
  String get language_label => getText('Bahasa', 'Language');
  String get city => getText('Kota', 'City');
  String get location => getText('Lokasi', 'Location');
  String get active => getText('Aktif', 'Active');
  String get inactive => getText('Nonaktif', 'Inactive');
  String get chooseLanguage => getText('Pilih Bahasa', 'Choose Language');
  String get chooseCity => getText('Pilih Kota', 'Choose City');
  String get close => getText('Tutup', 'Close');
  String get languageChanged => getText('Bahasa diubah ke', 'Language changed to');
  String get cityChanged => getText('Kota diubah ke', 'City changed to');
  String get customizeApp => getText('Sesuaikan aplikasi sesuai kebutuhan Anda', 'Customize the app to your needs');
  
  // ========================================
  // TRANSLATIONS - QURAN
  // ========================================
  String get quran => getText('Al-Quran', 'Al-Quran');
  String get surah => getText('Surat', 'Surah');
  String get ayah => getText('Ayat', 'Ayah');
  String get makkiyyah => getText('Makkiyyah', 'Makkiyah');
  String get madaniyyah => getText('Madaniyyah', 'Madaniyah');
  String get searchSurah => getText('Cari surat...', 'Search surah...');
  String get surahNotFound => getText('Surat tidak ditemukan', 'Surah not found');
  String get tryOtherKeyword => getText('Coba kata kunci lain', 'Try other keywords');
  
  // ========================================
  // TRANSLATIONS - FORMS
  // ========================================
  String get title => getText('Judul', 'Title');
  String get ustadz => getText('Ustadz', 'Teacher');
  String get theme => getText('Tema', 'Theme');
  String get date => getText('Tanggal', 'Date');
  String get time => getText('Waktu', 'Time');
  String get category => getText('Kategori', 'Category');
  String get notes => getText('Catatan', 'Notes');
  String get required => getText('wajib diisi', 'required');
  String get optional => getText('opsional', 'optional');
  
  // ========================================
  // TRANSLATIONS - BUTTONS & ACTIONS
  // ========================================
  String get saveChanges => getText('Simpan Perubahan', 'Save Changes');
  String get deleteKajian => getText('Hapus Kajian', 'Delete Kajian');
  String get editKajian => getText('Edit Kajian', 'Edit Kajian');
  String get areYouSure => getText('Apakah Anda yakin?', 'Are you sure?');
  String get yes => getText('Ya', 'Yes');
  String get no => getText('Tidak', 'No');
  
  // ========================================
  // TRANSLATIONS - MESSAGES
  // ========================================
  String get success => getText('Berhasil', 'Success');
  String get failed => getText('Gagal', 'Failed');
  String get error => getText('Error', 'Error');
  String get noData => getText('Tidak ada data', 'No data');
  String get loadingData => getText('Memuat data...', 'Loading data...');
  
  // ========================================
  // GREETING (waktu)
  // ========================================
  String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (_language == 'id') {
      if (hour < 11) return 'Selamat Pagi';
      if (hour < 15) return 'Selamat Siang';
      if (hour < 18) return 'Selamat Sore';
      return 'Selamat Malam';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
  }
}