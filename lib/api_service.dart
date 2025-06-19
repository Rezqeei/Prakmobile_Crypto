// lib/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';
import 'auth_service.dart';
import 'user_model.dart'; // Impor model User yang baru dibuat

class ApiService {
  final String baseUrl = "https://rest-api-berita.vercel.app/api/v1";
  final AuthService _authService = AuthService();

  // Helper untuk memproses semua respons dari API secara konsisten
  dynamic _processResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Beberapa respons API mungkin tidak memiliki 'data', langsung body itu sendiri datanya
      return body['data'] ?? body;
    } else {
      final message = body['message'] ?? 'Terjadi kesalahan tidak diketahui';
      throw Exception(message);
    }
  }

  // Helper untuk request yang memerlukan otentikasi (token)
  Future<http.Response> _authenticatedRequest(
      Future<http.Response> Function(String token) request) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Pengguna belum login. Silakan login terlebih dahulu.');
    }
    return await request(token);
  }

  /// Mengambil daftar artikel dengan dukungan pagination, kategori, dan pencarian.
  Future<List<Article>> getArticles(
      {String? category, int page = 1, int limit = 10, String? searchQuery}) async {
    var url = '$baseUrl/news?page=$page&limit=$limit';
    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }

    final response = await http.get(Uri.parse(url));
    final data = _processResponse(response);

    // --- PERBAIKAN DIMULAI DI SINI ---
    // Tambahkan pengecekan untuk memastikan data adalah Map dan memiliki key 'articles'
    if (data is Map<String, dynamic> && data.containsKey('articles') && data['articles'] is List) {
      final List<dynamic> articlesData = data['articles'];
      List<Article> articles = articlesData
          .map((json) => Article.fromJson(json))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        articles = articles.where((article) {
          return article.title.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      return articles;
    } else {
      // Jika struktur data tidak sesuai, kembalikan list kosong untuk mencegah crash
      return [];
    }
    // --- PERBAIKAN SELESAI ---
  }

  /// Melakukan login pengguna.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  /// Mendaftarkan pengguna baru.
  Future<Map<String, dynamic>> register(
      {required String email,
      required String password,
      required String name}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'title': 'Crypto Enthusiast',
        'avatar': 'https://api.dicebear.com/8.x/pixel-art/png?seed=$name'
      }),
    );
    return _processResponse(response);
  }

  /// Mengambil semua artikel yang telah di-bookmark oleh pengguna.
  Future<List<Article>> getBookmarkedArticles() async {
    final response = await _authenticatedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/news/bookmarks/list'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });
    final data = _processResponse(response);

    if (data is Map<String, dynamic> && data.containsKey('articles')) {
      final List<dynamic> articlesData = data['articles'];
      return articlesData.map((json) => Article.fromJson(json)).toList();
    } else if (data is List) {
      return data.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Format data bookmark tidak valid.');
    }
  }

  /// Memeriksa status bookmark sebuah artikel.
  Future<bool> checkBookmarkStatus(String articleId) async {
    final response = await _authenticatedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/news/$articleId/bookmark'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });
    final data = _processResponse(response);
    return data['isSaved'] ?? false;
  }

  /// Menambahkan artikel ke bookmark.
  Future<void> addBookmark(String articleId) async {
    await _authenticatedRequest((token) => http.post(
          Uri.parse('$baseUrl/news/$articleId/bookmark'),
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  /// Menghapus artikel dari bookmark.
  Future<void> removeBookmark(String articleId) async {
    await _authenticatedRequest((token) => http.delete(
          Uri.parse('$baseUrl/news/$articleId/bookmark'),
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  /// Mengambil artikel yang dibuat oleh pengguna.
  Future<List<Article>> getMyArticles() async {
    final response = await _authenticatedRequest((token) => http.get(
          Uri.parse('$baseUrl/news/user/me'),
          headers: {'Authorization': 'Bearer $token'},
        ));
    final data = _processResponse(response);
    final List<dynamic> articlesData = data['articles'];
    return articlesData.map((json) => Article.fromJson(json)).toList();
  }

  /// Membuat artikel baru.
  Future<void> createArticle(Map<String, dynamic> articleData) async {
    await _authenticatedRequest((token) => http.post(
          Uri.parse('$baseUrl/news'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(articleData),
        ));
  }

  /// Mengupdate artikel.
  Future<void> updateArticle(
      String articleId, Map<String, dynamic> articleData) async {
    await _authenticatedRequest((token) => http.put(
          Uri.parse('$baseUrl/news/$articleId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(articleData),
        ));
  }

  /// Menghapus artikel.
  Future<void> deleteArticle(String articleId) async {
    await _authenticatedRequest((token) => http.delete(
          Uri.parse('$baseUrl/news/$articleId'),
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // --- FUNGSI-FUNGSI BARU UNTUK PROFIL ---

  /// Mengambil data profil pengguna yang sedang login.
  Future<User> getMyProfile() async {
    final response = await _authenticatedRequest((token) => http.get(
          Uri.parse('$baseUrl/auth/me'), // Asumsi endpoint ini ada
          headers: {'Authorization': 'Bearer $token'},
        ));
    final data = _processResponse(response);
    return User.fromJson(data);
  }

  /// Mengupdate data profil pengguna.
  Future<void> updateProfile(Map<String, String> profileData) async {
    await _authenticatedRequest((token) => http.put(
          Uri.parse('$baseUrl/auth/update'), // Asumsi endpoint ini ada
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(profileData),
        ));
  }

  /// Mengganti password pengguna.
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _authenticatedRequest((token) => http.put(
          Uri.parse('$baseUrl/auth/change-password'), // Asumsi endpoint ini ada
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'oldPassword': oldPassword,
            'newPassword': newPassword,
          }),
        ));
  }
}