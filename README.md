# 📱 Kajian Scheduler – Mobile App

Aplikasi mobile berbasis Flutter yang digunakan untuk mengelola jadwal kajian Islami secara mudah.  
Fitur utama meliputi CRUD kajian, jadwal sholat real-time, Al-Qur'an digital, autentikasi Firebase, dark mode, statistik pengguna, serta multi-language (Indonesia & English).

---

## 📖 Deskripsi Singkat

**Kajian Scheduler** adalah aplikasi islami yang membantu pengguna:
- Menambahkan, mengedit, dan menghapus jadwal kajian
- Melihat jadwal sholat real-time berdasarkan lokasi
- Membaca 114 surah Al-Qur’an lengkap dengan terjemahan
- Mengatur tema aplikasi (light/dark mode)
- Menggunakan dua pilihan bahasa (Indonesia & English)
- Login & register menggunakan Firebase Authentication
- Menyimpan data kajian ke Firebase Firestore
- Menghitung statistik kajian secara otomatis

---

# ✨ Fitur Utama

### 🕌 1. Manajemen Kajian (CRUD)
- Tambah kajian baru (judul, ustadz, tema, waktu, lokasi, kategori)
- Edit kajian yang sudah dibuat
- Hapus kajian
- Mark status:  
  ✔️ “Sudah Dihadiri”  
  ✔️ “Akan Datang”  
- Search berdasarkan judul / ustadz / tema  
- Filter: Semua, Upcoming, Past  
- Mode Ba’da Sholat → waktu otomatis menyesuaikan jadwal sholat

---

### 🕒 2. Jadwal Sholat Real-Time
- Menggunakan **Aladhan Prayer Times API**
- Hitungan mundur real-time menuju sholat berikutnya (update per detik)
- Tanggal Hijriah otomatis
- Fallback offline jika tidak ada internet
- Membahas 13 kota Indonesia (Jakarta, Bandung, Malang, Surabaya, dll)

---

### 📖 3. Al-Qur'an Digital
Menggunakan **Quran API by Gading Dev**

- 114 surah lengkap  
- Teks Arab, transliterasi, dan terjemahan Indonesia  
- Filter Makkiyyah / Madaniyyah  
- Search surah  
- Pengaturan ukuran font  
- Toggle transliterasi  
- Mode tampilan gelap/terang

---

### 🌐 4. Multi-Language Support
- Bahasa Indonesia 🇮🇩  
- English 🇬🇧  
- Perubahan bahasa *real time* tanpa restart aplikasi

---

### 🌙 5. Dark Mode
- Light & Dark Theme  
- Menyimpan preferensi ke SharedPreferences  
- Animasi transisi lembut  

---

### 🔐 6. Authentication System
Menggunakan Firebase Authentication:
- Login email & password  
- Register akun baru  
- Reset password via email  
- Edit profile (nama & nomor telepon)  
- Ganti password  
- Logout dengan konfirmasi  

---

### 👤 7. User Stats
- Total kajian  
- Kajian bulan ini  
- Avatar otomatis dari inisial nama  

---

# 🛠 Teknologi yang Digunakan

| Teknologi | Keterangan |
|----------|------------|
| Flutter 3.x | Framework aplikasi mobile |
| Dart 3.x | Bahasa pemrograman |
| Firebase Authentication | Login, Register |
| Cloud Firestore | Penyimpanan data kajian |
| SharedPreferences | Local storage |
| Provider | State management |
| HTTP | Request ke API Aladhan & Qur'an |
| Aladhan API | Jadwal sholat |
| Quran API Gading Dev | Data Al-Qur’an |

---

# 🚀 Cara Instalasi

### 1. Clone Repository
git clone https://github.com/brynnstilearning/PraktikumMobile_UAS
cd PraktikumMobile_UAS
2. Install Dependencies
bash
Copy code
flutter pub get
3. Firebase Setup
Pastikan file google-services.json sudah berada di folder:
android/app/

Jika menggunakan Firebase sendiri:

bash
Copy code
flutterfire configure
4. Jalankan Aplikasi
bash
Copy code
flutter run
5. Build APK (Release)
bash
Copy code
flutter build apk --release

📚 Cara Penggunaan
🔹 1. Login / Register

Isi email & password

Untuk akun baru → tekan “Daftar Akun Baru”

Reset password tersedia

🔹 2. Dashboard

Greeting otomatis sesuai waktu

Statistik kajian

Daftar kajian yang bisa di-expand

🔹 3. Tambah Kajian

Tekan tombol +

Isi seluruh form

Simpan ke Firestore

🔹 4. Edit / Hapus Kajian

Expand card → pilih Edit atau Hapus

🔹 5. Jadwal Sholat

Melihat 5 waktu sholat harian

Countdown real-time

Bisa ubah kota dari menu Settings

🔹 6. Al-Qur’an Digital

114 surah tersedia

Bisa search, filter, atur font, dan baca detail ayat

🔹 7. Setelan Aplikasi

Dark Mode

Bahasa

Lokasi kota

About App

📁 Struktur Folder
```bash
lib/
├── models/
├── services/
│   ├── api/
│   ├── firebase/
├── providers/
├── screens/
├── widgets/
├── utils/
└── main.dart
```

📥 Download APK

Tambahkan file APK ke folder /apk/ lalu update link berikut:

👉 Download APK:
https://github.com/brynnstilearning/PraktikumMobile_UAS/releases

👨‍💻 Pengembang

Nama: Nur Muhammad Anang Febriananto
NIM: 230605110103
Prodi: Teknik Informatika
Universitas: UIN Maulana Malik Ibrahim Malang

📜 Lisensi

MIT License – bebas digunakan.

🙏 Acknowledgments

Aladhan API

Quran API by Gading Dev

Firebase

Flutter Community

UIN Malang

📞 Contact

Jika ada pertanyaan:

GitHub: https://github.com/brynnstilearning

Email pribadi: 230605110103@student.uin-malang.ac.id
