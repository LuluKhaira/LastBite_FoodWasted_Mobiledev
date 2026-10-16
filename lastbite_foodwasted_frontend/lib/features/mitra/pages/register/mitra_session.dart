// ============================================================
// mitra_session.dart
// ------------------------------------------------------------
// FUNGSI FILE INI:
// Membuat aplikasi "ingat" mitra yang sudah mendaftar tapi
// belum disetujui admin.
//
// KENAPA DIBUTUHKAN?
// Setelah mendaftar, mitra harus menunggu admin memeriksa data.
// Mitra pasti menutup aplikasi selama menunggu. Tanpa file ini,
// saat aplikasi dibuka lagi mitra kembali ke halaman awal dan
// tidak tahu status pendaftarannya.
//
// CARA KERJANYA:
// 1. Saat layar "Menunggu Verifikasi" terbuka, nomor WhatsApp
//    mitra disimpan di HP (savePendingPhone).
// 2. Saat aplikasi dibuka lagi, resumeScreen() membaca nomor itu,
//    menanyakan status terbaru ke server, lalu menentukan layar
//    yang harus dibuka:
//      - disetujui admin  -> layar "Disetujui"
//      - masih menunggu   -> layar "Menunggu Verifikasi"
//      - ditolak          -> layar "Menunggu Verifikasi" (tampil sebagai "Ditolak")
// 3. Kalau sudah disetujui atau mitra memilih daftar ulang,
//    nomor yang tersimpan dihapus (clear).
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lastbite_foodwasted_mobiledev/services/api_service.dart';
import 'mitra_disetujui_screen.dart';
import 'mitra_menunggu_verifikasi_screen.dart';

class MitraSession {
  // Nama "laci" tempat nomor WhatsApp disimpan di memori HP
  static const _key = 'pending_mitra_phone';

  // SIMPAN nomor WhatsApp mitra yang sedang menunggu verifikasi
  static Future<void> savePendingPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, phone);
  }

  // AMBIL nomor yang tersimpan (null kalau tidak ada)
  static Future<String?> getPendingPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // HAPUS nomor yang tersimpan
  // Dipanggil saat pendaftaran sudah disetujui, atau mitra memilih daftar ulang setelah ditolak
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // TENTUKAN layar yang harus dibuka saat aplikasi dibuka.
  //
  // Panggil fungsi ini di layar awal (splash). Hasilnya:
  //   - null            : tidak ada pendaftaran yang tertunda, lanjut ke alur biasa (login/beranda)
  //   - sebuah layar    : buka layar itu, karena mitra masih punya pendaftaran yang belum selesai
  static Future<Widget?> resumeScreen() async {
    // 1) Cek apakah ada nomor yang tersimpan
    final phone = await getPendingPhone();
    if (phone == null || phone.isEmpty) return null;

    // 2) Tanya status terbaru ke server (data dari keputusan admin di dashboard)
    final data = await ApiService.checkStatus(phone);

    // 3) Tidak ada internet / server tidak terjangkau:
    //    tetap buka layar menunggu, nanti status dicek ulang di layar itu
    if (data == null) return MitraMenungguVerifikasiScreen(phoneNumber: phone);

    // 4) Sudah disetujui admin: hapus ingatan, lalu buka layar "Disetujui"
    if (data['status'] == 'disetujui') {
      await clear();
      return const MitraDisetujuiScreen();
    }

    // 5) Masih menunggu atau ditolak: layar ini menampilkan keduanya
    return MitraMenungguVerifikasiScreen(phoneNumber: phone);
  }
}