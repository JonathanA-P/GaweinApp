# GaweIn - Platform Lowongan Kerja

GaweIn adalah sebuah platform aplikasi mobile terpadu yang menjembatani **Pencari Kerja** dengan **Perekrut** di perusahaan. Aplikasi ini dirancang untuk memudahkan proses melamar pekerjaan, pencarian kursus peningkatan karier, serta membangun ekosistem komunitas profesional bagi para penggunanya.

Aplikasi GaweIn saat ini difokuskan dan dioptimalkan untuk platform **Android**.

---

## Fitur-Fitur Aplikasi

### Fitur Utama (MVP)
* **Autentikasi Pengguna**
  - Registrasi & Login (Email & Password).
  - Lupa Password & Konfigurasi OTP/Recovery.
* **Peran (Role) saat register**
  - **Pencari Kerja**: Mampu melihat, mencari, dan melamar lowongan kerja.
  - **Perekrut / Perusahaan**: Mampu mempublikasikan dan mengelola lowongan kerja di perusahaan.
* **Manajemen Lowongan [MVP]**
  - Penambahan lowongan kerja oleh Perekrut.
  - Daftar pelamar pada setiap lowongan beserta fitur terima/tolak (Approval/Reject).
* **Melamar Pekerjaan [MVP]**
  - Pencarian lowongan beserta detail (gaji, deskripsi).
  - Proses melamar kerja (Apply) secara instan.
* **Kursus [MVP]**
  - Menyediakan kursus yang dapat diikuti pengguna.
 

### Fitur Pendukung
* **Komunitas**
  - Pembuatan postingan sharing pengalaman, gambar/foto.
  - Kolom komentar dan fitur Like/Love antar pengguna.
  - Sistem penghapusan konten otomatis dengan keamanan hapus kaskade (menghapus komentar terkait).
* **Profil & Personalisasi**
  - Biodata personal pengguna.
  - Pengelolaan profil dan update Avatar (Photo Profile).
* **Kursus & Edukasi**
  - Kurasi dan daftar kursus/pelatihan untuk meningkatkan skill Pencari Kerja (Tersedia tab kursus).

---

## Tech Stack & Platform
Aplikasi GaweIn dibangun menggunakan teknologi modern yang efisien:

### Frontend
- **Framework:** Flutter (Dart)
- **Target Platform (Cakupan):** **Android** 
- **State Management:** BLoC (Business Logic Component) via `flutter_bloc`
- **UI Components:** Material Design

### Backend & Database
- **Backend-as-a-Service:** Supabase (BaaS)
- **Database:** Supabase Data API)
- **Authentication:** Supabase Auth, Google oauth
- **Storage:** Supabase Cloud Storage (untuk menyimpan Avatar, Lampiran Profile, dan Gambar Postingan)

---

##  Arsitektur Aplikasi
Aplikasi ini diorganisasikan berdasarkan beberapa folder, yaitu

```
lib/
 ├── blocs/        # Berisi manajemen state (seperti AuthBloc)
 ├── models/       # Data/Entity model representatif dari database (UserModel, dsb)
 ├── screens/      # View/UI Pages (Login, Home, Lowongan, Komunitas, dll)
 ├── services/   
 ├── widgets/      # Komponen kustom yang dapat digunakan ulang (Reusable UI)
 └── main.dart     # Entry point dan inisialisasi aplikasi beserta Dependency Injection
```

## Panduan Memulai (Getting Started)

1. Pastikan Anda sudah menginstal **Flutter SDK** versi terbaru.
2. Clone repositori ini.
3. Buatlah file bernama `.env` di dalam root project dan tambahkan kunci Supabase Anda:
   ```env
   SUPABASE_URL=URL_SUPABASE_ANDA
   SUPABASE_ANON_KEY=ANON_KEY_SUPABASE_ANDA
   ```
4. Instal dependensi:
   ```bash
   flutter pub get
   ```
5. Jalankan aplikasi di Emulator Android atau Perangkat Fisik (Android):
   ```bash
   flutter run
   ```
