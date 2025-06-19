// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:prakmobile_crypto/auth_service.dart';
import 'package:prakmobile_crypto/login_page.dart';
import 'package:prakmobile_crypto/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      if (mounted && _pageController.page == 0) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
    super.initState();
  }

  // Data untuk setiap halaman onboarding
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/logo.png",
      "title": "Infoin",
      "subtitle": "",
      "isLogo": "true" // Tandai ini sebagai halaman logo
    },
    {
      "image": "assets/images/onboarding.jpg",
      "title": "Get the latest news\nfrom reliable sources",
      "subtitle": "",
      "isLogo": "false"
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Get actual news from\naround the world",
      "subtitle": "",
      "isLogo": "false"
    },
  ];

  // Fungsi untuk menandai bahwa onboarding telah selesai dan navigasi
  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan status bahwa onboarding sudah dilihat
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      // Ganti halaman saat ini dengan AuthCheck agar pengguna tidak bisa kembali ke onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthCheck()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang yang berubah sesuai halaman
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final item = _onboardingData[index];
              // Halaman pertama (splash screen) memiliki latar putih
              if (item["isLogo"] == "true") {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item['image']!, height: 100),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }
              // Halaman carousel dengan gambar latar
              return _buildPageContent(
                imagePath: item['image']!,
                title: item['title']!,
              );
            },
          ),
          // Kontrol di bagian bawah (tombol Skip, Next, Get Started)
          Positioned(
            bottom: 40.0,
            left: 24.0,
            right: 24.0,
            child: _buildBottomControls(),
          )
        ],
      ),
    );
  }

  // Widget untuk membangun konten halaman carousel
  Widget _buildPageContent({required String imagePath, required String title}) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun kontrol di bagian bawah
  Widget _buildBottomControls() {
    // Jangan tampilkan tombol apapun di halaman pertama (splash screen)
    if (_currentPage == 0) {
      return const SizedBox.shrink();
    }
    // Tampilkan tombol untuk halaman carousel
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Skip hanya muncul di halaman kedua
        if (_currentPage == 1)
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text('Skip',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        if (_currentPage != 1) const Spacer(), // Jaga posisi tombol kanan

        // Tombol Next atau Get Started
        ElevatedButton(
          onPressed: () {
            if (_currentPage < _onboardingData.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else {
              _finishOnboarding();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
              _currentPage == _onboardingData.length - 1
                  ? 'Get Started'
                  : 'Next',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
