import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFEAFDE1);
const _primary = Color(0xFF006B1E);
const _fieldBg = Color(0xFFE6F6DE);
const _infoBg = Color(0xFFDFF0D8);
const _textDark = Color(0xFF10260F);
const _textSoft = Color(0xFF3F4A3C);

class MitraRegisterScreen extends StatefulWidget {
  const MitraRegisterScreen({super.key});

  @override
  State<MitraRegisterScreen> createState() => _MitraRegisterScreenState();
}

class _MitraRegisterScreenState extends State<MitraRegisterScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _kirimKode() {
    final nomor = _phoneController.text.trim();

    if (nomor.length < 9 || nomor.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nomor WhatsApp yang valid, tanpa angka 0 di depan.'),
        ),
      );
      return;
    }

    debugPrint('Kirim kode ke +62$nomor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Progress langkah ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LANGKAH 1 DARI 7',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                        Text(
                          'Nomor WhatsApp',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: const LinearProgressIndicator(
                        value: 1 / 7,
                        minHeight: 8,
                        color: _primary,
                        backgroundColor: Color(0xFFD5EDCB),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Mulai dengan Nomor WhatsApp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftarkan nomor WhatsApp aktif toko atau pemilik untuk menerima notifikasi pesanan dan kode verifikasi.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.6,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nomor WhatsApp Aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Kotak kode negara
                              Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: _fieldBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const _IndonesiaFlag(),
                                    const SizedBox(width: 10),
                                    Text(
                                      '+62',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Input nomor
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  // Hanya boleh angka
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _textDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '812-3456-7890',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      color: const Color(0xFF7C8A78),
                                    ),
                                    filled: true,
                                    fillColor: _fieldBg,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: _primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.chat_outlined,
                                  size: 18, color: _primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Kami akan kirim kode verifikasi ke nomor ini.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: _textSoft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Kotak info "Komunikasi Cepat & Aman"
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _fieldBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFA5EE9E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified_outlined,
                                      color: _primary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Komunikasi Cepat & Aman',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Notifikasi pesanan surplus Lastbite dikirim langsung melalui WhatsApp.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          height: 1.5,
                                          color: _textSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Kartu "Bergabung dengan 1.200+ Mitra" ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _infoBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.storefront_outlined,
                                color: _primary, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bergabung dengan 1.200+ Mitra',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kurangi makanan terbuang dan dapatkan pendapatan tambahan setiap hari.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: _textSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _kirimKode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kirim Kode',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun mitra? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: _textSoft,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          debugPrint('Masuk di sini ditekan');
                        },
                        child: Text(
                          'Masuk di sini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
      color: const Color(0xFFEAFDE1),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _textDark),
            // Navigator.pop = kembali ke halaman sebelumnya.
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Mitra',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              Text(
                'Nomor Whatsapp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndonesiaFlag extends StatelessWidget {
  const _IndonesiaFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 30,
        height: 22,
        child: Column(
          children: [
            Expanded(child: Container(color: const Color(0xFFE70F3C))),
            Expanded(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}