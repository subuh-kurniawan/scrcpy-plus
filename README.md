# scrcpy-plus v3 — All-in-One Control Center & Single-Window Samsung DeX Suite

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Linux-2563EB?style=for-the-badge)
![scrcpy](https://img.shields.io/badge/scrcpy-3.3.4-059669?style=for-the-badge)
![Android](https://img.shields.io/badge/Android-5.0%20--%2015%2B-3DDC84?style=for-the-badge)
![License](https://img.shields.io/badge/License-Apache%202.0-7C3AED?style=for-the-badge)

**`scrcpy-plus v3`** adalah *suite* peluncur tingkat lanjut dan **GUI Control Center lintas-platform (macOS SwiftUI Native, Windows 10/11, & Linux)** untuk `scrcpy 3.3.4` dan `ADB` (Android Debug Bridge). Dirancang untuk mengubah perangkat Android apa pun menjadi **Workspace Desktop ala Samsung DeX (Jendela Tunggal Landscape & Multi-App)**, *webcam* HD, perangkat *streaming* gaming 60 FPS, serta pusat manajemen file & diagnostik *self-healing* tanpa ribet.

> **Developer & Maintainer:**  
> **Subuh Kurniawan** — [kurrniawansubuh@gmail.com](mailto:kurrniawansubuh@gmail.com)

---

## Daftar Isi

1. [Fitur Unggulan v3](#-fitur-unggulan-v3)
2. [Struktur File Repositori](#-struktur-file-repositori)
3. [Panduan Persiapan Awal HP Android (How-To)](#-panduan-persiapan-awal-hp-android-how-to)
4. [Cara Menjalankan di macOS, Windows, & Linux](#-cara-menjalankan-di-macos-windows--linux)
5. [Panduan Mode Samsung DeX (Jendela Tunggal Landscape)](#-panduan-mode-samsung-dex-jendela-tunggal-landscape)
6. [Panduan Koneksi Wi-Fi ADB & Pemindai Jaringan Lokal (LAN/mDNS)](#-panduan-koneksi-wi-fi-adb--pemindai-jaringan-lokal-lanmdns)
7. [Referensi Perintah CLI (`./scrcpy-plus`)](#-referensi-perintah-cli-scrcpy-plus)
8. [Daftar 14 Profil Siap Pakai](#-daftar-14-profil-siap-pakai)
9. [Pintasan Keyboard (Keyboard Shortcuts)](#-pintasan-keyboard-keyboard-shortcuts)
10. [Pemecahan Masalah (Troubleshooting & Doctor ADB)](#-pemecahan-masalah-troubleshooting--doctor-adb)
11. [Informasi Developer](#-informasi-developer)

---

## Fitur Unggulan v3

### 1. Mode Desktop Samsung DeX (Jendela Tunggal Landscape + Floating DeX Taskbar)
- **Semua Aplikasi di Dalam 1 Jendela DeX Tunggal**: Buka dan berpindah antar aplikasi (Chrome, WhatsApp, YouTube, Telegram, File Manager, dll.) **langsung di dalam 1 jendela DeX yang sama** (`am start --display <id>`) tanpa membuka jendela baru di komputer Anda.
- **Kunci Orientasi Landscape 16:9 / 21:9 (`@0` + `wm user-rotation lock`)**: Mengunci kanvas DeX secara horizontal (`1920x1080/160`, `1280x800/180`, atau Ultrawide `2560x1080/180`) sehingga aplikasi yang biasanya memaksa *portrait* (WhatsApp, Instagram, TikTok, m-Banking) tetap patuh di dalam layar mendatar DeX.
- **Floating DeX Taskbar & Start Menu**: Panel *taskbar* mengambang (*Always-on-Top*) untuk berpindah aplikasi aktif, membuka *Start Menu* seluruh aplikasi Android, memutar orientasi *Landscape ⇄ Portrait* secara *live*, mengatur **Live DPI / Zoom Slider** (`120–320 DPI`), dan mengambil *screenshot* kanvas DeX.
- **Paket Workspace 1-Klik, Split-Screen, & Mode Hybrid PiP**: Buka paket aplikasi sekaligus (*Kerja & Riset*, *Komunikasi*, *Hiburan*, *Kreator*), *Split-Screen* 2 aplikasi berdampingan (`--windowingMode 5`), atau pisahkan aplikasi tertentu ke jendela *Picture-in-Picture (Always-on-Top)*.

### 2. Ketangguhan Tinggi (*Self-Healing Watchdog* & *System Doctor*)
- **Auto-Recovery Session Watchdog**: Jika koneksi USB goyang atau sinyal Wi-Fi terputus mendadak, *watchdog* otomatis memulihkan *transport* ADB (`adb reconnect offline`) dan menyambungkan ulang sesi `scrcpy` / DeX dalam 2 detik.
- **1-Click System & ADB Doctor (`--doctor`)**: Memeriksa kesehatan binary `scrcpy` & `adb`, memperbaiki perangkat *offline/unauthorized*, membaca suhu baterai (`°C`) & pemakaian RAM (`GB`), serta mengaktifkan *flag* multi-window Android secara otomatis.
- **Proteksi Subprocess Timeout**: Mencegah UI membeku (*freeze*) ketika perintah ADB menghadapi jaringan Wi-Fi yang lambat.

### 3. Deteksi Jaringan Lokal Pintar (Android 11–15 `wlan0` & LAN/mDNS Scanner)
- **Deteksi IP Wi-Fi 5-Tahap (`wlan0` / `ap0`)**: Tetap akurat mendeteksi IP lokal (`192.168.x.x`) di Android 12/13/14/15 meskipun paket Data Seluler LTE (`seth_lte0` / `ccmni0` `10.x.x.x`) sedang menyala bersamaan.
- **Reverse-ARP Hotspot Wakeup**: Otomatis membangunkan tabel ARP dua arah antara HP dan PC/Mac saat menggunakan *Mobile Hotspot* agar tidak gagal dengan *incomplete ARP* atau *No route to host*.
- **Pemindai Jaringan Lokal (`--scan-wifi`)**: Memindai layanan mDNS *Wireless Debugging* (`_adb-tls-connect._tcp`), tabel ARP, dan port TCP `5555` di subnet lokal secara paralel.

### 4. File Explorer 2 Arah, Clipboard Sync, Kamera HD, & 14 Profil
- **2-Way Android File Explorer**: Jelajahi folder `/sdcard/Download`, `/sdcard/DCIM/Camera`, `/sdcard/Pictures`, lalu unduh (*Pull*) file ke komputer atau kirim (*Push* / *Drag & Drop*) file & `.apk` ke HP.
- **Sinkronisasi & Riwayat Clipboard (PC/Mac ⇄ Android)**: Salin dan tempel teks dua arah beserta riwayat 12 klip terakhir.
- **Mirroring Kamera / Webcam (Android 12+) & Streaming Audio (Android 11+)**: Jadikan kamera HP sebagai webcam 1080p/60fps dan duplikasikan suara HP ke komputer (`--audio-dup`).

---

## Struktur File Repositori

| Nama File / Folder | Platform | Deskripsi |
| :--- | :--- | :--- |
| `scrcpy-plus` | macOS & Linux | Skrip utama CLI & mesin otomatisasi DeX, Wi-Fi scanner, File Explorer, dan System Doctor |
| `scrcpy-plus-gui.swift` | macOS (14.0+) | Kode sumber lengkap aplikasi GUI native macOS berbasis **SwiftUI + AppKit** |
| `scrcpy-plus-gui.app` | macOS (arm64/x64) | Bundel aplikasi `.app` macOS siap pakai (dilengkapi *MenuBarExtra* & izin *Local Network*) |
| `scrcpy-plus-gui-crossplatform.py` | Windows & Linux | Aplikasi GUI lengkap lintas-platform berbasis Python 3 (`tkinter/ttk` *Dark Theme*) |
| `scrcpy-plus-windows.bat` | Windows 10/11 | Launcher klik-ganda untuk Windows (juga mendukung `--build-exe` via PyInstaller) |
| `scrcpy-plus-linux.sh` | Linux | Launcher GUI & CLI untuk distro Linux (Ubuntu, Debian, Fedora, Arch) |
| `scrcpy-plus.desktop` | Linux Desktop | Pintasan menu aplikasi standar FreeDesktop untuk Linux |

---

## Panduan Persiapan Awal HP Android (How-To)

Lakukan langkah ini **sekali saja** pada perangkat Android Anda:

1. **Aktifkan Opsi Pengembang (*Developer Options*)**:
   - Buka **Pengaturan (Settings)** → **Tentang Ponsel (About Phone)**.
   - Ketuk **Nomor Bentukan (Build Number)** sebanyak **7 kali** hingga muncul notifikasi *"You are now a developer!"*.
2. **Aktifkan USB Debugging & Kontrol Penuh**:
   - Buka **Pengaturan** → **Sistem** → **Opsi Pengembang (Developer Options)**.
   - Aktifkan **USB Debugging**.
   - **Sangat Penting (Xiaomi / POCO / OPPO / Vivo / Realme / Transsion / itel / Infinix)**: Aktifkan juga opsi **"USB debugging (Security settings)"** atau **"Disable permission monitoring"** (Matikan pemantauan izin) agar klik mouse, ketikan keyboard, dan peluncuran aplikasi di *Virtual Display DeX* berjalan 100% lancar.
3. **Otorisasi Komputer**:
   - Hubungkan HP ke komputer menggunakan kabel USB, pilih mode **File Transfer (MTP)**, centang **"Always allow from this computer"**, lalu ketuk **Allow / Izinkan**.

---

## Cara Menjalankan di macOS, Windows, & Linux

### A. macOS (Native SwiftUI App)

Klik ganda **`scrcpy-plus-gui.app`** di Finder, atau jalankan melalui Terminal:

```bash
./scrcpy-plus --gui
# atau
open scrcpy-plus-gui.app
```

Jika Anda ingin mengompilasi ulang `scrcpy-plus-gui.app` dari kode sumber `scrcpy-plus-gui.swift`:

```bash
swiftc -O -parse-as-library \
  -module-cache-path /tmp/swift-module-cache \
  -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
  -target arm64-apple-macosx14.0 \
  scrcpy-plus-gui.swift \
  -o scrcpy-plus-gui.app/Contents/MacOS/scrcpy-plus-gui && \
codesign --force --deep --sign - scrcpy-plus-gui.app
```

---

### B. Windows 10 / 11 (GUI Launcher & Standalone `.exe`)

1. Pastikan file `scrcpy.exe` dan `adb.exe` berada di dalam folder yang sama (atau sudah terdaftar di `PATH` Windows), serta Python 3 terinstal.
2. **Klik ganda `scrcpy-plus-windows.bat`** untuk langsung membuka jendela GUI tanpa jendela Command Prompt.
3. **Opsional — Membuat File `scrcpy-plus-gui.exe` Mandiri (Tanpa Perlu Python di PC Lain)**:
   ```bat
   scrcpy-plus-windows.bat --build-exe
   ```
   Perintah di atas otomatis mengemas aplikasi menjadi `scrcpy-plus-gui.exe` menggunakan `PyInstaller`.

---

### C. Linux (Ubuntu / Debian / Fedora / Arch)

1. Pastikan paket `scrcpy`, `adb`, dan `python3-tk` sudah terinstal:
   ```bash
   # Ubuntu / Debian
   sudo apt update && sudo apt install -y scrcpy adb python3 python3-tk netcat-openbsd

   # Fedora
   sudo dnf install -y scrcpy android-tools python3 python3-tkinter nmap-ncat

   # Arch Linux
   sudo pacman -S scrcpy android-tools python tk openbsd-netcat
   ```
2. Jalankan GUI dengan perintah:
   ```bash
   chmod +x scrcpy-plus scrcpy-plus-linux.sh scrcpy-plus-gui-crossplatform.py
   ./scrcpy-plus-linux.sh
   ```

---

## Panduan Mode Samsung DeX (Jendela Tunggal Landscape)

1. Buka aplikasi GUI lalu pilih menu **`DeX Desktop Workspace`** di sidebar.
2. Pada bagian **Mode Orientasi DeX**, pastikan terpilih **`Landscape (16:9 Horizontal Terkunci)`** dan pilih resolusi kanvas (misalnya `Landscape Full HD 1920x1080/160` atau `Ultrawide 2560x1080/180`).
3. Klik tombol **`Start DeX (1 Jendela)`** atau klik salah satu ikon aplikasi di kanvas DeX.
4. **Berpindah Aplikasi Tanpa Buka Jendela Baru**:
   - Gunakan **Floating DeX Taskbar** (jendela kecil yang selalu berada di atas layar), **Dock DeX**, atau **Start Menu** untuk mengeklik aplikasi lain (mis. dari *Chrome* ke *WhatsApp* atau *YouTube*).
   - Aplikasi akan langsung tampil di dalam jendela DeX yang sama!
5. **Fitur Tambahan DeX**:
   - Geser **Slider Ukuran Antarmuka (Live DPI)** (`120–320`) untuk memperbesar/memperkecil tampilan di layar DeX secara *real-time* tanpa me-*restart* sesi.
   - Klik **Paket Workspace 1-Klik** atau **Split-Screen 2 Aplikasi** untuk membuka beberapa aplikasi sekaligus dalam mode *Freeform*.

---

## Panduan Koneksi Wi-Fi ADB & Pemindai Jaringan Lokal (LAN/mDNS)

Pastikan komputer dan HP Android terhubung ke jaringan Wi-Fi atau Hotspot yang sama:

- **Cara 1 — Otomatis via Kabel USB (1-Klik)**:
  1. Hubungkan kabel USB sebentar.
  2. Klik tombol **`Aktifkan Wi-Fi`** di *Dashboard* (atau **`Auto USB → Wi-Fi (5555)`** di menu *Wi-Fi & Pairing ADB*).
  3. Aplikasi otomatis mendeteksi IP `wlan0` HP, mengaktifkan port `5555`, membangunkan tabel ARP, dan menyambungkan koneksi. Cabut kabel USB dan lanjutkan tanpa kabel!
- **Cara 2 — Scan Jaringan Lokal (Tanpa Kabel USB)**:
  1. Buka menu **`Wi-Fi & Pairing ADB`**.
  2. Klik tombol **`Scan Jaringan Lokal (LAN & mDNS)`**.
  3. Klik tombol IP perangkat Android yang muncul untuk langsung terhubung.
- **Cara 3 — Pairing Kode 6 Digit (Android 11–15 Wireless Debugging)**:
  1. Di HP Android, buka *Developer Options* → *Wireless Debugging* → *Pair device with pairing code*.
  2. Masukkan `IP:Port Pairing` dan `6 Digit Kode` pada kartu *Wireless Debugging Pairing*, lalu klik **Pair Perangkat**.

---

## Referensi Perintah CLI (`./scrcpy-plus`)

```bash
# Tampilkan panduan singkat & info developer di terminal
./scrcpy-plus --howto

# Jalankan System & ADB Doctor (Auto-Fix koneksi & cek kesehatan baterai/RAM)
./scrcpy-plus --doctor

# Pindai perangkat Android di jaringan Wi-Fi lokal (LAN, mDNS, ARP & Port 5555)
./scrcpy-plus --scan-wifi

# Mode Gaming 60 FPS dengan bitrate 20M
./scrcpy-plus --profile gaming --fps 60 --bitrate 20M

# Mode Samsung DeX Jendela Tunggal Landscape + buka Chrome
./scrcpy-plus --profile desktop --start-app +?chrome

# Buka / ganti aplikasi di dalam Virtual Display DeX yang sedang berjalan (tanpa buka jendela baru)
./scrcpy-plus --launch-on-display auto com.whatsapp --landscape

# Ubah orientasi atau DPI layar DeX secara live saat sesi berjalan
./scrcpy-plus --display-rotation auto landscape
./scrcpy-plus --display-dpi auto 160

# Ambil screenshot layar utama HP atau layar DeX
./scrcpy-plus --screenshot ~/Desktop/hp.png
./scrcpy-plus --screenshot-display auto ~/Desktop/dex.png

# Mirror kamera belakang HP 1080p 60fps (Android 12+)
./scrcpy-plus --profile camera --camera-facing back --camera-size 1920x1080 --camera-fps 60

# Jelajahi & unduh file dari HP ke komputer
./scrcpy-plus --list-files /sdcard/Download
./scrcpy-plus --pull /sdcard/Download/dokumen.pdf ~/Downloads/
```

---

## Daftar 14 Profil Siap Pakai

| Nama Profil | Kegunaan Utama | Konfigurasi Otomatis |
| :--- | :--- | :--- |
| `gaming` | Bermain game 60 FPS responsif | Fullscreen, 60 FPS, 20M bitrate, indikator sentuhan aktif |
| `desktop` | Workspace Desktop ala Samsung DeX | Virtual Display `1920x1080/160` Landscape, IME tersembunyi, 60 FPS |
| `productivity` | Kerja harian & balas chat | Jaga HP tetap menyala (`-w`), 8M bitrate |
| `studio` | Demo aplikasi & konten tajam | Codec H.265, 15M bitrate, indikator sentuhan aktif |
| `recording` | Rekam layar & suara kualitas tinggi | Rekam MP4 ke Desktop, 30M bitrate + output audio |
| `presentation` | Presentasi layar penuh | Fullscreen, indikator sentuhan aktif, 12M bitrate |
| `private` | Privasi penuh & hemat baterai HP | Layar fisik HP dimatikan (`-S`) + mati otomatis saat ditutup |
| `camera` | Jadikan HP sebagai Webcam HD | `--video-source=camera`, 1080p, 30/60 FPS |
| `audio-only` | Streaming musik/suara HP ke PC/Mac | Tanpa jendela video (`--no-video`), streaming audio murni |
| `low-latency` | Koneksi Wi-Fi jarak jauh / lambat | Resolusi maks 1024px, 4M bitrate, 60 FPS |
| `windowed` | Jendela standar di desktop | Mode jendela normal, 9M bitrate |
| `debug` | Pengujian aplikasi & pantau FPS | Indikator sentuhan + `--print-fps` di log konsol |
| `otg` | Keyboard & Mouse fisik via USB | Mode HID `--otg` tanpa perlu USB Debugging / video |
| `default` | Standar bawaan `scrcpy` | Konfigurasi standar `scrcpy 3.3.4` |

---

## Pintasan Keyboard (Keyboard Shortcuts)

> Gunakan **`Option (⌥)`** di **macOS** atau **`Alt`** di **Windows & Linux**:

| Pintasan (macOS) | Pintasan (Windows / Linux) | Fungsi |
| :--- | :--- | :--- |
| `Option + F` | `Alt + F` | Beralih mode Fullscreen / Windowed |
| `Option + H` | `Alt + H` | Tombol **Home** Android |
| `Option + B` | `Alt + B` | Tombol **Back** (Kembali) |
| `Option + S` | `Alt + S` | Tombol **Recent Apps / App Switcher** |
| `Option + P` | `Alt + P` | Tombol **Power** (Nyalakan/Matikan layar) |
| `Option + O` | `Alt + O` | **Matikan layar fisik HP saja** (Mirror di komputer tetap menyala) |
| `Option + Shift + O` | `Alt + Shift + O` | **Nyalakan kembali layar fisik HP** |
| `Option + R` | `Alt + R` | Putar orientasi layar `scrcpy` |
| `Option + G` | `Alt + G` | Ubah ukuran jendela ke piksel asli 1:1 |
| `Option + ↑ / ↓` | `Alt + ↑ / ↓` | Perbesar / Perkecil Volume HP |

---

## Pemecahan Masalah (Troubleshooting & Doctor ADB)

1. **Muncul Pesan `No route to host` atau Wi-Fi ADB Tidak Terdeteksi**:
   - Klik tombol **`Doctor`** di bagian atas aplikasi GUI (atau jalankan `./scrcpy-plus --doctor`).
   - Jika menggunakan koneksi **Hotspot HP**, hubungkan kabel USB sekali lalu klik **`Auto USB → Wi-Fi (5555)`** agar fitur *Reverse-ARP Wakeup* mendaftarkan alamat MAC HP ke tabel ARP komputer secara otomatis.
   - Di **macOS Sequoia (macOS 15+)**, pastikan izin akses jaringan lokal untuk `scrcpy-plus` diaktifkan pada *System Settings → Privacy & Security → Local Network*. <img width="3178" height="1900" alt="CleanShot 2026-10-28 at 09 46 04@2x" src="https://github.com/user-attachments/assets/211d4c87-132a-47d9-b105-f81f94148301" />
<img width="3040" height="1760" alt="CleanShot 2026-10-28 at 09 46 38@2x" src="https://github.com/user-attachments/assets/ffa5eb8c-fd7d-49af-a76f-99657361eca5" />
<img width="3036" height="1758" alt="CleanShot 2026-10-28 at 09 46 52@2x" src="https://github.com/user-attachments/assets/f33d31cb-ab56-436a-81ab-216689ef51aa" />
<img width="3046" height="1766" alt="CleanShot 2026-10-28 at 09 47 07@2x" src="https://github.com/user-attachments/assets/bebdc545-4254-4549-b22c-372e0c97e1db" />
<img width="3054" height="1768" alt="CleanShot 2026-10-28 at 09 47 25@2x" src="https://github.com/user-attachments/assets/cc1abdeb-c93f-4d1a-aed1-629f0c525360" />
<img width="3050" height="1770" alt="CleanShot 2026-10-28 at 09 47 41@2x" src="https://github.com/user-attachments/assets/4151309d-a908-4e0f-919a-2a044ca103ef" />
<img width="3048" height="1768" alt="CleanShot 2026-10-28 at 09 47 58@2x" src="https://github.com/user-attachments/assets/78324a99-9eeb-4bfa-98fa-8920467336e3" />
<img width="3052" height="1774" alt="CleanShot 2026-10-28 at 09 48 12@2x" src="https://github.com/user-attachments/assets/75060038-e8fb-46fa-ae24-eb5e4ff5b0e0" />
<img width="3048" height="1770" alt="CleanShot 2026-10-28 at 09 48 24@2x" src="https://github.com/user-attachments/assets/39bcef18-5468-421c-af95-10168c18ea93" />
<img width="3060" height="1776" alt="CleanShot 2026-10-28 at 09 48 36@2x" src="https://github.com/user-attachments/assets/a97b033e-6a17-48cf-a80f-71dfb4e25ad5" />
<img width="3360" height="2100" alt="CleanShot 2026-10-28 at 09 49 09@2x" src="https://github.com/user-attachments/assets/3faf2b08-9204-49cd-a1c4-3cd522ff2a31" />

2. **Aplikasi di Mode DeX Terbuka di Layar HP (Bukan di Jendela DeX)**:
   - Pastikan opsi **`Pindah App dari Layar HP (--force-stop awal)`** dicentang di pengaturan DeX agar Android memindahkan *activity task* aplikasi dari layar fisik HP (`Display #0`) ke *Virtual Display DeX*.

---
<img width="3360" height="2100" alt="CleanShot 2026-10-28 at 09 49 20@2x" src="https://github.com/user-attachments/assets/6744608f-d969-450a-8c08-c1039557b593" />

## Informasi Developer

Dikembangkan dan dikelola oleh:

- **Nama Developer**: **Subuh Kurniawan**
- **Email**: [kurrniawansubuh@gmail.com](mailto:kurrniawansubuh@gmail.com)
- **Basis Mesin**: [Genymobile/scrcpy 3.3.4](https://github.com/Genymobile/scrcpy) (Apache-2.0 License)
