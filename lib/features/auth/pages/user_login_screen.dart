import 'package:flutter/material.dart';

// Ganti ke halaman Beranda Anda nanti jika sudah ada
// import 'halaman_beranda.dart'; 

class UserLoginScreen extends StatelessWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3E2B)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                ),
                onPressed: () {
                  // Aksi bantuan
                },
                icon: const Icon(Icons.headset_mic_outlined, size: 16, color: Color(0xFF0F3E2B)),
                label: const Text(
                  'Butuh Bantuan?',
                  style: TextStyle(color: Color(0xFF0F3E2B), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Atas (Selamat Datang Kembali)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFEFEF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1F5E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🌱 LastBite Movement',
                                style: TextStyle(
                                  color: Color(0xFF0F3E2B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Selamat Datang Kembali',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F3E2B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Lanjutkan misi menyelamatkan pangan lezat bernutrisi.',
                              style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFEAF4EE),
                          child: const Center(
                            child: Text('🍞', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tab Switcher (Nomor WhatsApp & Email & Sandi)
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: const Color(0xFF0F3E2B),
                    unselectedLabelColor: const Color(0xFF666666),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                    tabs: const [
                      Tab(text: '📱 Nomor WhatsApp'),
                      Tab(text: '✉️ Email & Sandi'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Konten Tab (Tinggi disesuaikan dengan isi)
                SizedBox(
                  height: 220,
                  child: TabBarView(
                    children: [
                      // --- TAB 1: NOMOR WHATSAPP ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Nomor WhatsApp atau HP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('★ Paling Cepat • Aktif & Siap', style: TextStyle(color: Colors.red, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E5E5)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEFEF),
                                  ),
                                  child: const Text('🇮🇩 +62', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: '812 3456 7890',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Contoh: 0812 3456 7890 (Kode OTP dikirim otomatis ke WhatsApp).',
                            style: TextStyle(color: Color(0xFF888888), fontSize: 11),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1F5E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle, color: Color(0xFF0F3E2B), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Masuk Tanpa Kata Sandi (via Kode Angka WhatsApp)',
                                    style: TextStyle(color: Color(0xFF0F3E2B), fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // --- TAB 2: EMAIL & SANDI ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'nama@email.com',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tombol Lanjutkan Masuk -> Mengarah ke Halaman OTP (Mockup)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3E2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Langsung diarahkan ke halaman OTP simulasi sesuai gambar pertama[cite: 11]
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MockOtpScreen()),
                      );
                    },
                    child: const Text(
                      'Lanjutkan Masuk →',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(child: Text('ATAU MASUK INSTAN DENGAN', style: TextStyle(color: Color(0xFF999999), fontSize: 10))),
                const SizedBox(height: 12),

                // Tombol Alternatif
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E5E5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                  ),
                  onPressed: () {
                    // Langsung ke beranda (bypass)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MockHomeMockScreen()),
                    );
                  },
                  child: const Text('Gunakan Akun Google', style: TextStyle(color: Color(0xFF333333), fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN SIMULASI OTP (Sesuai Gambar Pertama)[cite: 11]
// ==========================================
class MockOtpScreen extends StatelessWidget {
  const MockOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Verifikasi Akun', style: TextStyle(color: Color(0xFF0F3E2B), fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan Kode Verifikasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F3E2B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kode 6 digit rahasia telah kami kirimkan ke WhatsApp Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
            const SizedBox(height: 32),
            // Simulasi Kotak OTP statis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => Container(
                width: 45,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0F3E2B), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    ['4', '8', '2', '1', '5', '9'][index],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E2B)),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 40),
            // Tombol Verifikasi & Masuk -> Langsung ke Beranda
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MockHomeMockScreen()),
                  );
                },
                child: const Text('Verifikasi & Masuk →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN SIMULASI BERANDA (Tujuan Akhir)
// ==========================================
class MockHomeMockScreen extends StatelessWidget {
  const MockHomeMockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🎉', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text(
              'Selamat Datang di Beranda LastBite!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E2B)),
            ),
            SizedBox(height: 8),
            Text('Anda berhasil masuk ke aplikasi.', style: TextStyle(color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}