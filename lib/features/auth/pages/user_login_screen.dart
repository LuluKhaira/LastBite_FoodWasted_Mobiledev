import 'package:flutter/material.dart';


class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  // Untuk memilih tab metode login (Nomor WhatsApp vs Email & Sandi)
  bool isWhatsAppSelected = true;
  final TextEditingController _phoneController = TextEditingController(text: '812 3456 7890');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BAGIAN ATAS: Tombol Kembali & Bantuan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F2),
                      shape: const CircleBorder(),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.headset_mic_outlined, size: 18, color: Colors.black87),
                    label: const Text(
                      'Butuh Bantuan?',
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F2),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. KOTAK KARTU SAMBUTAN (SELAMAT DATANG KEMBALI)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEBEFEA)),
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
                              color: const Color(0xFFD4EDDA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LastBite Movement',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF155724),
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
                          const SizedBox(height: 6),
                          const Text(
                            'Lanjutkan misi menyelamatkan pangan lezat bernutrisi dan merawat kelestarian bumi kita.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.bakery_dining, size: 36, color: Color(0xFF0F3E2B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. PILIHAN TAB (Nomor WhatsApp vs Email & Sandi)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isWhatsAppSelected = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isWhatsAppSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isWhatsAppSelected
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.phone_android, size: 16, color: Colors.black87),
                              SizedBox(width: 6),
                              Text('Nomor WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isWhatsAppSelected = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isWhatsAppSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !isWhatsAppSelected
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.email_outlined, size: 16, color: Colors.black87),
                              SizedBox(width: 6),
                              Text('Email & Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. FORM INPUT NOMOR WHATSAPP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Nomor WhatsApp atau HP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  Text('★ Paling Cepat  Aktif & Siap Menerima Pesan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Text('🇮🇩', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 4),
                          Text('+62', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '812 3456 7890',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _phoneController.clear(),
                      icon: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Contoh pengisian: 0812 3456 7890 (Kode OTP akan dikirim otomatis ke akun WhatsApp Anda).',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // 5. INFO KOTAK HIJAU MUDA (Masuk Tanpa Kata Sandi)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_user, color: Color(0xFF2E7D32), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Masuk Tanpa Kata Sandi\nKami mengirimkan kode angka 6 digit lewat WhatsApp',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6. TOMBOL UTAMA (Lanjutkan Masuk)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3E2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Lanjutkan Masuk',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // GARIS PEMBATAS
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('ATAU MASUK INSTAN DENGAN', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),

              // 7. TOMBOL SOSIAL MEDIA
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                    Text('Lanjutkan dengan Akun Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.mail_outline, size: 18, color: Color(0xFF0F3E2B)),
                    SizedBox(width: 8),
                    Text('Kirim Tautan Masuk Ajaib (Magic Link)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 8. TEKS BELUM MEMILIKI AKUN
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum memiliki akun LastBite? ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Daftar Akun Baru',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F3E2B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 9. FOOTER
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Privasi Anda terjaga. Masuk berarti menyetujui Ketentuan Layanan & Kebijakan Privasi LastBite.',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF0F3E2B)),
                        SizedBox(width: 6),
                        Text(
                          'Mengalami kesulitan masuk? Bantuan Admin WhatsApp',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F3E2B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}