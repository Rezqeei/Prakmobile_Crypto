// lib/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_profile'; // Kunci untuk menyimpan data user

  // --- Token Management ---
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // --- User Profile Management (BARU) ---

  /// Menyimpan data profil pengguna ke SharedPreferences.
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Konversi map ke string JSON untuk disimpan
    await prefs.setString(_userKey, json.encode(userData));
  }

  /// Mengambil data profil pengguna dari SharedPreferences.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      // Konversi string JSON kembali ke map
      return json.decode(userString);
    }
    return null;
  }

  /// Menghapus data profil pengguna dari SharedPreferences.
  Future<void> deleteUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // --- Logout (DIPERBARUI) ---
  Future<void> logout() async {
    // Hapus token dan juga data profil saat logout
    await deleteToken();
    await deleteUserProfile();
  }
}