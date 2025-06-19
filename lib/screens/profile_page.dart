// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:prakmobile_crypto/login_page.dart';
import '../api_service.dart';
import '../auth_service.dart';
import '../user_model.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Ubah future untuk mengambil data dari lokal
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Ambil data dari SharedPreferences
    _userFuture = _authService.getUserProfile();
    // Statistik tetap dari API
    _statsFuture = _getStats();
    setState(() {});
  }

  Future<Map<String, int>> _getStats() async {
    final myArticles = await _apiService.getMyArticles();
    final bookmarkedArticles = await _apiService.getBookmarkedArticles();
    return {
      'created': myArticles.length,
      'bookmarked': bookmarkedArticles.length,
    };
  }

  void _handleLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Profil tidak ditemukan. Coba login ulang.'));
          }

          // Buat objek User dari data lokal
          final user = User.fromJson(snapshot.data!);

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 24),
                _buildMenuList(context, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(user.avatar),
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(user.email, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildStats() {
    return FutureBuilder<Map<String, int>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(count: stats['created']!, label: 'Artikel Dibuat'),
            _StatItem(count: stats['bookmarked']!, label: 'Disimpan'),
          ],
        );
      },
    );
  }

  Widget _buildMenuList(BuildContext context, User user) {
    return Column(
      children: [
         ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Edit Profil'),
           subtitle: const Text('Endpoint API tidak tersedia'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Fitur ini belum dapat digunakan karena tidak ada endpoint API untuk update profil.'),
              duration: Duration(seconds: 3),
            ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Ganti Password'),
          subtitle: const Text('Endpoint API tidak tersedia'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Fitur ini belum dapat digunakan karena tidak ada endpoint API untuk ganti password.'),
              duration: Duration(seconds: 3),
            ));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: _handleLogout,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }
}