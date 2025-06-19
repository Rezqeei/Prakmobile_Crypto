import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'screens/main_screen.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  final _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.login(
          _emailController.text, _passwordController.text);
          
      // PERBAIKAN: Langsung ambil 'token' dari response
      final token = response['token'];

      await _authService.saveToken(token);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        // Menampilkan pesan error yang lebih bersih dari ApiService
        SnackBar(content: Text('Login Gagal: ${e.toString().replaceFirst("Exception: ", "")}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_open, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text('Selamat Datang Kembali', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              Text('Login untuk melanjutkan', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ),
                child: const Text('Belum punya akun? Daftar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}