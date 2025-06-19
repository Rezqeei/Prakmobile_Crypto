import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = "https://rest-api-berita.vercel.app/api/v1";
  final AuthService _authService = AuthService();

  // Helper untuk memproses semua respons dari API secara konsisten
  dynamic _processResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['data'] == null) {
        throw Exception("Data dari server kosong.");
      }
      return body['data'];
    } else {
      final message = body['message'] ?? 'Terjadi kesalahan tidak diketahui';
      throw Exception(message);
    }
  }
  
  // Helper untuk request yang memerlukan otentikasi (token)
  Future<http.Response> _authenticatedRequest(Future<http.Response> Function(String token) request) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Pengguna belum login. Silakan login terlebih dahulu.');
    }
    return await request(token);
  }

  /// Mengambil daftar artikel dengan dukungan pagination.
  Future<List<Article>> getArticles({String? category, int page = 1, int limit = 10}) async {
    var url = '$baseUrl/news?page=$page&limit=$limit';
    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }
    final response = await http.get(Uri.parse(url));
    final data = _processResponse(response);
    final List<dynamic> articlesData = data['articles'];
    return articlesData.map((json) => Article.fromJson(json)).toList();
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
      {required String email, required String password, required String name}) async {
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
    
    // PERBAIKAN: Menangani kasus di mana API mengembalikan Map berisi List
    if (data is Map<String, dynamic> && data.containsKey('articles')) {
       final List<dynamic> articlesData = data['articles'];
       return articlesData.map((json) => Article.fromJson(json)).toList();
    } 
    else if (data is List) {
       return data.map((json) => Article.fromJson(json)).toList();
    } 
    else {
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
  Future<void> updateArticle(String articleId, Map<String, dynamic> articleData) async {
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
}