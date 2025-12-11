📱 Kajian Scheduler - Mobile App
<p align="center">
  <img src="assets/logo.png" alt="Kajian Scheduler Logo" width="200"/>
</p>
<p align="center">
  <i>Aplikasi Mobile untuk Mengelola Jadwal Kajian Islami Anda</i>
</p>
<p align="center">
  <img src="screenshots/splash.png" width="200"/>
  <img src="screenshots/dashboard.png" width="200"/>
  <img src="screenshots/prayer.png" width="200"/>
  <img src="screenshots/quran.png" width="200"/>
</p>
Aplikasi manajemen jadwal kajian Islami yang membantu umat Muslim mengatur dan melacak kehadiran kajian dengan mudah. Fitur utama mencakup CRUD kajian, jadwal sholat real-time, Al-Qur'an digital, multi-language support (Indonesia & English), dan dark mode.

📋 Daftar Isi

Fitur Utama
Teknologi & API
Endpoint API yang Digunakan
Arsitektur Aplikasi
Cara Instalasi
Panduan Penggunaan
Testing Results
Pengembang


✨ Fitur Utama
📚 Manajemen Kajian (CRUD)

Create: Tambah kajian baru dengan detail lengkap (judul, ustadz, tema, tanggal, waktu, lokasi, kategori)
Read: Lihat daftar kajian dengan filter (All, Upcoming, Past)
Update: Edit detail kajian yang sudah ada
Delete: Hapus kajian dengan konfirmasi
Search: Cari kajian berdasarkan judul, ustadz, atau tema
Toggle Status: Tandai kajian sebagai "Sudah Dihadiri" atau "Akan Datang"
Ba'da Sholat Mode: Set waktu kajian otomatis setelah sholat tertentu
Data disimpan di Firebase Firestore

🕌 Jadwal Sholat Real-Time

Menampilkan 5 waktu sholat harian berdasarkan lokasi pengguna
Countdown real-time ke sholat berikutnya (update setiap detik dengan format JAM:MENIT:DETIK)
Support 13 kota besar di Indonesia (Jakarta, Surabaya, Bandung, Medan, Semarang, Makassar, Palembang, Tangerang, Malang, Depok, Yogyakarta, Bogor, Bekasi)
Tanggal Hijriah otomatis
Data diambil dari Aladhan Prayer Times API
Fallback mechanism saat tidak ada koneksi internet

📖 Al-Qur'an Digital

Daftar lengkap 114 surah dengan teks Arab, transliterasi, dan terjemahan Indonesia
Filter berdasarkan wahyu (Makkiyyah/Madaniyyah)
Search surah by name atau translation
Detail surah dengan ayat-ayat lengkap
Adjustable font size untuk Arab & terjemahan
Toggle transliterasi on/off
Dark card design untuk kenyamanan membaca
Data diambil dari Quran API by Gading Dev

🌐 Multi-Language Support

Bahasa Indonesia 🇮🇩
English 🇬🇧
Switch language real-time tanpa restart app
Semua UI & text ter-translate otomatis

🌓 Dark Mode Support

Toggle dark/light theme
Persist preference ke SharedPreferences
Smooth transition animation

🔐 Authentication System

Firebase Authentication untuk login & registrasi
Register dengan nama, email, password, dan nomor telepon
Login dengan email & password
Forgot Password dengan email reset link
Edit profile (nama & nomor telepon)
Change password dengan verifikasi password lama
Logout dengan konfirmasi

👤 User Profile & Stats

Dashboard dengan greeting berdasarkan waktu
Statistik kajian real-time:

Total kajian (dari Firebase)
Kajian bulan ini (auto-filtered by date)


Edit profile & change password
User avatar dengan initial huruf pertama nama


🛠 Teknologi & API
Framework & State Management

Flutter 3.0+ - Cross-platform mobile framework
Provider - State management (AuthProvider, SettingsProvider)
Dart 3.x - Programming language

Backend & Database

Firebase Core ^2.25.4
Firebase Authentication ^4.17.4 - User authentication
Cloud Firestore ^4.15.4 - NoSQL database untuk kajian
SharedPreferences ^2.2.2 - Local storage untuk settings & cache

HTTP & API Integration

http ^1.2.0 - HTTP client untuk API calls

External APIs

Aladhan Prayer Times API

Endpoint: https://api.aladhan.com/v1
Purpose: Jadwal sholat berdasarkan lokasi & tanggal Hijriah


Quran API by Gading Dev

Endpoint: https://api.quran.gading.dev
Purpose: Data Al-Qur'an lengkap dengan terjemahan Indonesia



UI Libraries

table_calendar ^3.0.9 - Calendar widget untuk date picker
intl ^0.19.0 - Internationalization & date formatting


🌐 Endpoint API yang Digunakan
1. Aladhan Prayer Times API
Get Prayer Times by City
GET https://api.aladhan.com/v1/timingsByCity/{date}
Parameters:

city (string) - Nama kota (contoh: "Malang")
country (string) - Nama negara (contoh: "Indonesia")
method (int) - Calculation method (default: 20 - KEMENAG Indonesia)

Response Example:
json{
  "code": 200,
  "status": "OK",
  "data": {
    "timings": {
      "Fajr": "04:30",
      "Sunrise": "05:47",
      "Dhuhr": "12:00",
      "Asr": "15:15",
      "Maghrib": "18:00",
      "Isha": "19:15"
    },
    "date": {
      "gregorian": {
        "day": "12",
        "month": { "number": "12" },
        "year": "2024",
        "weekday": { "en": "Monday" }
      },
      "hijri": {
        "day": "13",
        "month": { "en": "Rabiul Akhir" },
        "year": "1447"
      }
    }
  }
}
Implementasi:
dart// File: lib/services/api/prayer_service_api.dart

Future<Map<String, dynamic>> _fetchPrayerTimes({
  String? city,
  String? country,
}) async {
  try {
    final url = Uri.parse(
      '$baseUrl/timingsByCity/${DateFormat('dd-MM-yyyy').format(DateTime.now())}'
      '?city=${city ?? _currentCity}&country=${country ?? _currentCountry}&method=20'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200 && data['status'] == 'OK') {
        _cachedData = data['data'];
        _lastFetch = DateTime.now();
        return _cachedData!;
      }
    }
    
    // Fallback to dummy data on error
    return _getDummyData();
  } catch (e) {
    print('❌ Error fetching prayer times: $e');
    return _getDummyData();
  }
}
```

**Error Handling:**
- Timeout after 10 seconds
- Fallback ke data dummy jika gagal
- Cache data selama 1 jam untuk mengurangi API calls

---

### 2. Quran API by Gading Dev

#### Get All Surah List
```
GET https://api.quran.gading.dev/surah
Response Example:
json{
  "code": 200,
  "data": [
    {
      "number": 1,
      "name": {
        "short": "الفاتحة",
        "transliteration": {
          "id": "Al-Fatihah"
        },
        "translation": {
          "id": "Pembukaan"
        }
      },
      "numberOfVerses": 7,
      "revelation": {
        "id": "Mekkah"
      }
    }
    // ... 113 surah lainnya
  ]
}
Implementasi:
dart// File: lib/services/api/quran_service_api.dart

@override
Future<List<Surat>> loadSuratList() async {
  if (_cachedSuratList != null) {
    print('📦 Using cached surat list');
    return _cachedSuratList!;
  }
  
  try {
    print('📖 Fetching surat list from API...');
    
    final url = Uri.parse('$baseUrl/surah');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['code'] == 200) {
        final List<dynamic> suratData = data['data'];
        
        _cachedSuratList = suratData.map((json) {
          // Parse revelation type dengan benar
          String revelationType = 'Makkiyyah';
          
          if (json['revelation'] != null && json['revelation']['id'] != null) {
            String revType = json['revelation']['id'].toString().toLowerCase();
            
            if (revType.contains('madinah') || revType.contains('madaniyyah')) {
              revelationType = 'Madaniyyah';
            }
          }
          
          return Surat(
            number: json['number'],
            name: json['name']['transliteration']['id'],
            nameArabic: json['name']['short'],
            nameTranslation: json['name']['translation']['id'],
            revelationType: revelationType,
            numberOfAyat: json['numberOfVerses'],
          );
        }).toList();
        
        print('✅ Loaded ${_cachedSuratList!.length} surat');
        return _cachedSuratList!;
      }
    }
    
    throw Exception('Failed to load surat list: ${response.statusCode}');
  } catch (e) {
    print('❌ Error loading surat list: $e');
    return [];
  }
}
```

#### Get Surah Detail with Verses
```
GET https://api.quran.gading.dev/surah/{surahNumber}
Response Example:
json{
  "code": 200,
  "data": {
    "number": 1,
    "numberOfVerses": 7,
    "name": {
      "short": "الفاتحة",
      "transliteration": { "id": "Al-Fatihah" }
    },
    "verses": [
      {
        "number": { "inSurah": 1 },
        "text": {
          "arab": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
          "transliteration": {
            "en": "Bismillaahir Rahmaanir Raheem"
          }
        },
        "translation": {
          "id": "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang."
        }
      }
      // ... ayat lainnya
    ]
  }
}
Implementasi:
dart@override
Future<Surat?> loadSuratDetail(int suratNumber) async {
  // Return cache jika ada
  if (_cachedSuratDetails.containsKey(suratNumber)) {
    print('📦 Using cached surat $suratNumber');
    return _cachedSuratDetails[suratNumber];
  }
  
  try {
    print('📖 Fetching surat $suratNumber from API...');
    
    final url = Uri.parse('$baseUrl/surah/$suratNumber');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['code'] == 200) {
        final suratData = data['data'];
        
        // Parse ayat-ayat
        final List<dynamic> versesData = suratData['verses'];
        final List<Ayat> ayatList = versesData.map((verse) {
          return Ayat(
            number: verse['number']['inQuran'],
            numberInSurat: verse['number']['inSurah'],
            textArabic: verse['text']['arab'],
            textTransliteration: verse['text']['transliteration']['en'],
            textTranslation: verse['translation']['id'],
          );
        }).toList();
        
        // Buat object Surat lengkap
        final surat = Surat(
          number: suratData['number'],
          name: suratData['name']['transliteration']['id'],
          nameArabic: suratData['name']['short'],
          nameTranslation: suratData['name']['translation']['id'],
          revelationType: /* ... parse revelation type ... */,
          numberOfAyat: suratData['numberOfVerses'],
          ayatList: ayatList,
        );
        
        // Cache
        _cachedSuratDetails[suratNumber] = surat;
        
        print('✅ Loaded surat ${surat.name} with ${ayatList.length} ayat');
        return surat;
      }
    }
    
    throw Exception('Failed to load surat detail: ${response.statusCode}');
  } catch (e) {
    print('❌ Error loading surat $suratNumber: $e');
    return null;
  }
}
```

---

## 🏗 Arsitektur Aplikasi

### Layer Architecture
```
lib/
├── models/                    # Data models
│   ├── user_model.dart        # User entity (with phoneNumber)
│   ├── kajian_model.dart      # Kajian entity
│   ├── surat_model.dart       # Surat entity
│   └── ayat_model.dart        # Ayat entity
│
├── services/                  # Business logic & API calls
│   ├── auth_service.dart      # Auth wrapper
│   ├── kajian_service.dart    # Kajian wrapper
│   ├── prayer_service.dart    # Prayer wrapper
│   ├── quran_service.dart     # Quran wrapper
│   ├── storage_service.dart   # Local storage (SharedPreferences)
│   │
│   ├── interfaces/            # Service interfaces (abstraction)
│   │   ├── auth_service_interface.dart
│   │   ├── kajian_service_interface.dart
│   │   ├── prayer_service_interface.dart
│   │   └── quran_service_interface.dart
│   │
│   ├── firebase/              # Firebase implementations
│   │   ├── auth_service_firebase.dart      # Firebase Auth
│   │   └── kajian_service_firebase.dart    # Firestore Kajian
│   │
│   └── api/                   # API implementations
│       ├── prayer_service_api.dart   # ✅ HTTP GET Prayer Times
│       └── quran_service_api.dart    # ✅ HTTP GET Quran Data
│
├── providers/                 # State management
│   ├── auth_provider.dart     # Auth state (login, register, logout)
│   └── settings_provider.dart # Settings (theme, language, city)
│
├── screens/                   # UI Pages
│   ├── splash_screen.dart           # Entry screen
│   ├── login_screen.dart            # Login page
│   ├── register_screen.dart         # Register page
│   ├── forgot_password_screen.dart  # Forgot password page
│   ├── dashboard_screen.dart        # Home with kajian list
│   ├── add_kajian_screen.dart       # Create kajian
│   ├── edit_kajian_screen.dart      # Update kajian
│   ├── prayer_times_screen.dart     # ✅ Consume Prayer API
│   ├── quran_list_screen.dart       # ✅ Consume Quran API (List)
│   ├── quran_detail_screen.dart     # ✅ Consume Quran API (Detail)
│   ├── profile_screen.dart          # User profile with stats
│   ├── edit_profile_screen.dart     # Edit profile page
│   ├── change_password_screen.dart  # Change password page
│   └── settings_screen.dart         # App settings
│
├── widgets/                   # Reusable components
│   ├── bottom_nav_bar.dart    # Custom bottom navigation
│   ├── custom_button.dart     # Reusable button
│   ├── custom_text_field.dart # Reusable text input
│   └── kajian_card.dart       # Expandable kajian card
│
├── utils/                     # Helper utilities
│   ├── date_formatter.dart    # Date formatting helpers
│   └── validators.dart        # Form validators
│
├── config/                    # App configuration
│   ├── theme.dart             # Theme definitions (light/dark)
│   ├── constants.dart         # App constants
│   └── service_config.dart    # Service factory (Firebase/API)
│
└── main.dart                  # Entry point
```

### State Management Flow
```
User Action (Tap Button)
    ↓
Screen (UI Layer)
    ↓
Provider (State Management)
    ↓
Service (Business Logic + HTTP Request)  ✅ API Call Here
    ↓
HTTP Response → JSON Parsing → Model
    ↓
Provider notifyListeners()
    ↓
Screen Rebuild (Show Data)
Error Handling Strategy
dart// Contoh di prayer_service_api.dart

Future<Map<String, dynamic>> _fetchPrayerTimes({
  String? city,
  String? country,
}) async {
  try {
    // 1. Try API Call
    final response = await http.get(url).timeout(
      const Duration(seconds: 10),
    );
    
    if (response.statusCode == 200) {
      // Success: Parse & return data
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      // HTTP Error: Use fallback
      return _getDummyData();
    }
  } catch (e) {
    // Network Error: Use fallback
    print('❌ Error: $e');
    return _getDummyData();
  }
}

// Fallback with hardcoded data
Map<String, dynamic> _getDummyData() {
  return {
    'timings': {
      'Fajr': '04:30',
      'Dhuhr': '12:00',
      'Asr': '15:15',
      'Maghrib': '18:00',
      'Isha': '19:15',
    },
    // ... dummy data lainnya
  };
}
Asynchronous UI Pattern
1. FutureBuilder Pattern (untuk API calls):
dart// Menggunakan FutureBuilder
FutureBuilder<List<Surat>>(
  future: QuranService().loadSuratList(),
  builder: (context, snapshot) {
    // Loading State
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Error State
    if (snapshot.hasError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: ${snapshot.error}'),
            ElevatedButton(
              onPressed: () => setState(() {}), // Retry
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    
    // Empty State
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('Tidak ada data'));
    }
    
    // Success State
    final surahList = snapshot.data!;
    return ListView.builder(
      itemCount: surahList.length,
      itemBuilder: (context, index) {
        return SurahCard(surat: surahList[index]);
      },
    );
  },
)
2. RefreshIndicator (untuk pull-to-refresh):
dartRefreshIndicator(
  onRefresh: _loadKajian,
  child: ListView.builder(
    // ... list items
  ),
)
3. Timer untuk Real-Time Countdown:
dartTimer? _countdownTimer;

void _startCountdownTimer() {
  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() {
        _calculateRemainingTime();
      });
    }
  });
}

@override
void dispose() {
  _countdownTimer?.cancel();
  super.dispose();
}

📥 Cara Instalasi
Prerequisites

Flutter SDK ≥ 3.0.0
Dart SDK ≥ 3.0.0
Android Studio / VS Code
Git
Firebase Project (sudah dikonfigurasi)

Step-by-Step Installation
1. Clone Repository
bashgit clone https://github.com/YOUR_USERNAME/kajian-scheduler.git
cd kajian-scheduler
2. Install Dependencies
bashflutter pub get
3. Firebase Setup
Aplikasi ini sudah dikonfigurasi dengan Firebase. File konfigurasi sudah ada di repository.
Jika ingin menggunakan Firebase project sendiri:
bash# Install Firebase CLI
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Configure FlutterFire
flutterfire configure
Manual Firebase Setup:

Buat project di Firebase Console
Tambahkan aplikasi Android
Download google-services.json → Taruh di android/app/
Enable Firebase Authentication (Email/Password)
Enable Cloud Firestore

4. Run Application
Android:
bashflutter run
iOS (Mac only):
bashcd ios
pod install
cd ..
flutter run
5. Build APK (Release)
bashflutter build apk --release
APK akan tersimpan di: build/app/outputs/flutter-apk/app-release.apk

📖 Panduan Penggunaan
1. Registrasi & Login
Buat Akun Baru:

Tap "Daftar Akun Baru" di halaman login
Isi: Nama Lengkap, Email, Nomor Telepon, Password (min 6 karakter)
Tap "Daftar"
Otomatis redirect ke Dashboard setelah berhasil

Login:

Masukkan Email & Password
Tap "Masuk"

Lupa Password:

Tap "Lupa Password?" di halaman login
Masukkan email terdaftar
Tap "Kirim Link Reset"
Cek inbox email untuk link reset password

2. Dashboard (Home)

Header: Greeting berdasarkan waktu + nama user + tanggal hari ini
Filter Chips:

"Semua" - Tampilkan semua kajian
"Akan Datang" - Filter kajian upcoming
"Sudah Lewat" - Filter kajian past


Kajian Card (Expandable):

Tap untuk expand/collapse detail
Lihat: Judul, Ustadz, Waktu, Lokasi, Tema, Catatan, Kategori
Toggle "Tandai Selesai" untuk mark sebagai attended
Tap "Edit" untuk ubah data
Tap "Hapus" untuk delete kajian


Floating Action Button (+): Tambah kajian baru
Pull to Refresh: Swipe down untuk reload data dari Firebase

3. Tambah Kajian

Tap tombol + (Floating Action Button)
Isi form:

Judul Kajian: Contoh "Kajian Tafsir Al-Baqarah"
Nama Ustadz: Contoh "Ustadz Ahmad"
Tema Kajian: Contoh "Tafsir Al-Quran Juz 1-2"
Pilih Tanggal: Tap untuk buka calendar
Pilih Waktu:

Manual: Pilih jam & menit dari time picker
Ba'da Sholat: Pilih salah satu (Ba'da Subuh, Dzuhur, Ashar, Maghrib, Isya) - waktu otomatis sesuai jadwal sholat


Lokasi: Contoh "Masjid Agung Malang"
Kategori: Pilih dari 6 kategori (Tafsir, Hadits, Fiqih, Akhlaq, Sejarah, Lainnya)
Catatan: Opsional, untuk informasi tambahan


Tap "Simpan Kajian"

4. Edit Kajian

Expand kajian card → Tap "Edit"
Update field yang ingin diubah
Ubah status: "Akan Datang" atau "Sudah Lewat"
Tap "Simpan Perubahan"

5. Hapus Kajian

Expand kajian card → Tap "Hapus"
Konfirmasi dialog → Tap "Ya, Hapus"
Data terhapus dari Firebase secara permanen

6. Jadwal Sholat

Tap menu "Sholat" (ikon masjid) di bottom nav
Lihat 5 waktu sholat dengan icon berbeda:

Subuh/Terbit/Dhuha: 🌅 (wb_twilight)
Dzuhur: ☀️ (wb_sunny)
Ashar: ☁️ (wb_cloudy)
Maghrib: 🌙 (brightness_3)
Isya: 🌃 (nights_stay)


Countdown Real-Time:

Sholat berikutnya ditandai dengan border pink + countdown JAM:MENIT:DETIK
Counter update setiap detik


Tanggal Hijriah: Tampil di card bawah
Ubah Lokasi: Settings → Lokasi → Pilih kota (13 pilihan)
Pull to Refresh: Swipe down untuk reload jadwal sholat

7. Al-Qur'an Digital
List Surah:

Tap menu "Al-Quran" (ikon buku) di bottom nav
Lihat 114 surah dengan info:

Nomor surah
Nama transliterasi
Nama Arab (kanan)
Terjemahan
Jumlah ayat
Badge Makkiyyah/Madaniyyah


Search: Ketik nama surah di search bar
Filter:

"Semua" - 114 surah
"Makkiyyah" - Surah turun di Mekkah
"Madaniyyah" - Surah turun di Madinah



Detail Surah:

Tap surah untuk buka detail
Tampilan:

Header: Nama Arab, terjemahan, badge (Makkiyyah/Madaniyyah, jumlah ayat)
Bismillah: Otomatis tampil (kecuali At-Taubah)
Ayat-ayat:

Nomor ayat (kotak hijau)
Teks Arab (RTL, font besar)
Transliterasi (opsional)
Terjemahan Indonesia




Settings (tap FAB):

Toggle "Tampilkan Transliterasi"
Slider "Ukuran Font Arab" (20-40)
Slider "Ukuran Font Terjemahan" (12-24)



8. Profile

Tap menu "Profil" di bottom nav
Lihat:

Avatar: Initial huruf pertama nama
Nama & Email
Nomor Telepon (jika diisi)
Statistik Kajian:

Total Kajian: Jumlah semua kajian dari Firebase
Bulan Ini: Auto-filtered kajian bulan berjalan
Loading state saat fetch data




Menu:

Edit Profil: Ubah nama & nomor telepon (email tidak bisa diubah)
Ganti Password: Ubah password dengan verifikasi password lama
Keluar: Logout dengan konfirmasi



9. Settings

Tap menu "Pengaturan" di bottom nav
Tampilan:

Toggle "Tema Gelap" - Switch dark/light mode


Bahasa:

Tap untuk pilih: 🇮🇩 Indonesia / 🇬🇧 English
Semua UI ter-translate real-time


Lokasi:

Tap untuk pilih kota (untuk jadwal sholat)
13 pilihan: Jakarta, Surabaya, Bandung, Medan, Semarang, Makassar, Palembang, Tangerang, Malang, Depok, Yogyakarta, Bogor, Bekasi


Tentang:

Lihat info aplikasi & versi



10. Multi-Language
Aplikasi support 2 bahasa dengan terjemahan lengkap:
Bahasa Indonesia (Default):

Semua UI dalam Bahasa Indonesia
Tanggal format: "Senin, 12 Desember 2024"
Greeting: "Selamat Pagi/Siang/Sore/Malam"
