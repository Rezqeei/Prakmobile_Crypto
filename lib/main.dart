// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prakmobile_crypto/screens/onboarding_screen.dart'; // Import halaman onboarding
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk cek status
import 'screens/main_screen.dart';
import 'auth_service.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF007AFF);
    const Color backgroundColor = Color(0xFFF2F2F7);
    const Color surfaceColor = Colors.white;
    const Color textColor = Color(0xFF1D1D1F);

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme(
        Theme.of(context).textTheme.apply(
              bodyColor: textColor,
              displayColor: textColor,
            ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textColor,
        onSurface: textColor,
        error: Colors.red,
        onError: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1.0,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 1.0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
      ),
    );

    return MaterialApp(
      title: 'Crypto News',
      theme: lightTheme,
      // Ganti home dari AuthCheck menjadi StartupCheck
      home: const StartupCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// WIDGET BARU: Pengecekan awal saat aplikasi dibuka
class StartupCheck extends StatefulWidget {
  const StartupCheck({super.key});

  @override
  State<StartupCheck> createState() => _StartupCheckState();
}

class _StartupCheckState extends State<StartupCheck> {
  // Fungsi untuk memeriksa apakah onboarding sudah pernah dilihat
  Future<bool> _checkIfOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika 'hasSeenOnboarding' belum ada, kembalikan false
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfOnboardingSeen(),
      builder: (context, snapshot) {
        // Saat sedang memeriksa, tampilkan loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Jika sudah selesai memeriksa
        if (snapshot.hasData && snapshot.data == true) {
          // Jika sudah melihat onboarding, langsung ke AuthCheck
          return const AuthCheck();
        } else {
          // Jika belum, tampilkan OnboardingScreen
          return const OnboardingScreen();
        }
      },
    );
  }
}


// Widget AuthCheck tidak perlu diubah
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}