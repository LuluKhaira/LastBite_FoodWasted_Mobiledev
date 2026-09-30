import 'package:flutter/material.dart';
import 'user_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Data teks sesuai desain Figma
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Jelajahi toko sekitar Batam',
      'description': 'Temukan paket kejutan berisi makanan sisa dari restoran, bakery, dan usaha di dekatmu.',
      'image': '🏠',
    },
    {
      'title': 'Pesan & bayar di muka',
      'description': 'Pilih paketmu, bayar lewat aplikasi, dan paketmu terkunci untukmu.',
      'image': '🛍️',
    },
    {
      'title': 'Ambil dengan kode',
      'description': 'Tunjukkan QR atau kode 6 digit ke toko, lalu ambil pesananmu.',
      'image': '📱',
    },
    {
      'title': 'Sisa jadi berguna',
      'description': 'Jadi makanan, pakan, atau pupuk. Hemat untukmu, baik untuk bumi.',
      'image': '🌱',
    },
  ];

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Bagian Atas: Tombol "Lewati" (Hanya muncul jika bukan slide terakhir)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentIndex < _onboardingData.length - 1)
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 40), // Penyeimbang tinggi jika 'Lewati' hilang
                ],
              ),
              const SizedBox(height: 10),

              // Bagian Slider Utama
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ilustrasi / Icon Emoji (bisa diganti Image.asset jika pakai gambar asli Figma)
                        Container(
                          width: 160,
                          height: 160,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF4EE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _onboardingData[index]['image']!,
                              style: const TextStyle(fontSize: 70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3E2B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _onboardingData[index]['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indikator Titik (Dots) di Tengah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? const Color(0xFF0F3E2B) : const Color(0xFFD4DED8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bagian Bawah: Tombol Navigasi (Dinamis sesuai Slide)
              SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Jika di slide terakhir, tampilkan tombol "Kembali" di kiri
                    if (_currentIndex == _onboardingData.length - 1)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            color: Color(0xFF0F3E2B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(), // Kosongkan jika bukan slide terakhir

                    // Tombol Kanan ("Lanjut" teks biasa atau tombol "Mengerti")
                    if (_currentIndex < _onboardingData.length - 1)
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Lanjut',
                          style: TextStyle(
                            color: Color(0xFF0F3E2B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3E2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: _navigateToLogin,
                        child: const Text(
                          'Mengerti',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}