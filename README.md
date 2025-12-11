# Kajian Scheduler – Mobile App

Aplikasi mobile untuk membantu umat Muslim mengatur jadwal kajian, mendapatkan informasi sholat real-time, membaca Al-Qur'an digital, serta melacak kehadiran kajian dengan mudah. Mendukung CRUD kajian, multi-language (Indonesia & English), dark mode, dan banyak fitur lainnya.

---

## 📌 Daftar Isi
- [Fitur Utama](#fitur-utama)
- [Teknologi & Tools](#teknologi--tools)
- [Manajemen Kajian CRUD](#manajemen-kajian-crud)
- [Sholat Real-Time](#sholat-real-time)
- [Al-Quran Digital](#alquran-digital)
- [Multi-Language](#multi-language)
- [Dark Mode](#dark-mode)
- [Authentication System](#authentication-system)
- [User Profile & Stats](#user-profile--stats)
- [API Endpoint & Error Handling](#api-endpoint--error-handling)
- [Code Example](#code-example)

---

## ✨ Fitur Utama

### 🔹 Manajemen Kajian (CRUD)
- **Create**: Tambah kajian baru (judul, ustadz, tema, tanggal, waktu, lokasi, kategori).
- **Read**: Lihat daftar kajian dengan filter (hari, lokasi, kategori).
- **Update**: Edit detail kajian.
- **Delete**: Hapus kajian.
- **Search**: Cari kajian berdasarkan judul, ustadz, tema.
- **Status Toggle**:  
  - *"Sudah Dihadiri"*,  
  - *"Akan Datang"*,  
  - *"Batal"*
- **Sholat Mode**: Set status otomatis berdasarkan waktu sholat.
- **Penyimpanan**: Firebase Firestore.

---

## 🕒 Sholat Real-Time
Menampilkan **5 waktu sholat harian** berdasarkan lokasi pengguna dengan:

- Hitungan mundur *real-time* menuju sholat berikutnya.
- Update otomatis setiap detik (`HH:MM:SS`).
- 10+ kota besar Indonesia sebagai default fallback:
  - Jakarta, Surabaya, Bandung, Medan, Semarang, Makassar, Palembang, Batam, Denpasar, Malang, Yogyakarta.
- **Data API**: Aladhan Prayer Times API.
- **Fallback Mode**: Tersedia data offline jika tidak ada koneksi.

---

## 📖 Al-Qur'an Digital
Termasuk:

- Daftar **114 surat** lengkap dengan teks Arab, transliterasi, dan terjemahan Bahasa Indonesia.
- Filter berdasarkan jenis wahyu (*Makkiyah / Madaniyyah*).
- Pencarian surat dan ayat.
- Pengaturan tampilan:
  - Font Arab adjustable.
  - Toggle transliterasi.
  - Dark/Light optimized typography.
- Data diambil dari **Qur'an API by Gading Dev**.

---

## 🌍 Multi-Language Support
- Bahasa Indonesia 🇮🇩 & English 🇺🇸  
- Switch bahasa tanpa restart aplikasi  
- Semua UI & teks otomatis berubah  
- Dukungan Provider (SettingsProvider)  

---

## 🌙 Dark Mode
- Memakai theme persistence menggunakan SharedPreferences  
- Smooth animated transitions  

---

## 🔐 Authentication System
Menggunakan Firebase Authentication:

- Login dengan Email/Password
- Register pengguna baru
- Reset password
- Edit profile (nama & nomor telepon)
- Verifikasi password sebelum update sensitif
- Logout  
- Avatar dibuat otomatis berdasarkan initial  

---

## 👤 User Profile & Stats

Dashboard statistik real-time:

- Total kajian (dari Firebase)
- Kajian bulan ini (auto-filter by date)
- Grafik sederhana jumlah kegiatan
- Edit profil & ganti password

---

## 🛠 Teknologi & Tools

### Frontend
- **Flutter 3.x**
- **Dart 3.x**
- Provider State Management  
  - `AuthProvider`  
  - `SettingsProvider`  
  - dll.

### Backend & Database
- Firebase Core `^2.25.4`
- Firebase Authentication `^4.17.4`
- Cloud Firestore `^4.15.4`
- SharedPreferences `^2.2.2`
- Local Storage untuk settings & cache

### Networking
- `http ^1.2.0` – REST API client

---

## 🔌 API Endpoint & Error Handling

### Qur'an API (Gading Dev)

#### Endpoint: Get All Surah List
GET https://apiquran.gading.dev/surah

css
Copy code

**Response Example:**
```json
{
  "code": 200,
  "data": [
    {
      "number": 1,
      "name": {
        "short": "الفاتحة",
        "transliteration": { "id": "Al-Fatihah" },
        "translation": { "id": "Pembukaan" }
      },
      "numberOfVerses": 7,
      "revelation": { "id": "Mekah" }
    }
  ]
}
⚠️ Error Handling
Auto-timeout 10 seconds

Auto fallback ke dummy data

Cache data 1 jam untuk mengurangi API calls

Try-catch di semua request

🧩 Code Example
Load Surah List
dart
Copy code
@override
Future<List> loadSuratList() async {
  if (_cachedSuratList != null) {
    print("📦 Using cached surat list");
    return _cachedSuratList!;
  }

  try {
    print("📡 Fetching surat list from API...");
    final url = Uri.parse('${baseUrl}/surah');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['code'] == 200) {
        final List<dynamic> suratData = data['data'];

        _cachedSuratList = suratData.map((json) {
          String revelationType = "Makkiyyah";

          if (json['revelation'] != null &&
              json['revelation']['id'] != null) {
            final revType = json['revelation']['id']
                .toString()
                .toLowerCase();
            if (revType.contains("madinah")) {
              revelationType = "Madaniyyah";
            }
          }

          return Surat(
            number: json['number'],
            nameArabic: json['name']['short'],
            nameLatin: json['name']['transliteration']['id'],
            nameTranslation: json['name']['translation']['id'],
            revelationType: revelationType,
            numberOfAyat: json['numberOfVerses'],
          );
        }).toList();

        print("📥 Loaded ${_cachedSuratList!.length} surat");
        return _cachedSuratList!;
      }
      throw Exception("Failed to load surat list: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error loading surat list: $e");
    return [];
  }
}
📦 Status Proyek
✔️ Sudah berjalan penuh
✔️ Semua fitur utama selesai
✔️ API stabil
✔️ Siap dikembangkan lebih lanjut

📜 Lisensi
MIT License – bebas digunakan & dimodifikasi.
