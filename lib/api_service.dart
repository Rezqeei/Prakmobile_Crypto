import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = "https://rest-api-berita.vercel.app/api/v1";
  final AuthService _authService = AuthService();

  /// Mengambil daftar artikel.
  /// Bisa difilter berdasarkan [category] jika disediakan.
  Future<List<Article>> getArticles({String? category}) async {
    var url = '$baseUrl/news';
    if (category != null && category.isNotEmpty) {
      url += '?category=$category';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> articlesData = responseData['data']['articles'];
      return articlesData.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat artikel');
    }
  }

  /// Melakukan login pengguna.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal login: ${error['message']}');
    }
  }

  /// Mendaftarkan pengguna baru.
  Future<Map<String, dynamic>> register(
      {required String email, required String password, required String name}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'name': name,
        'title': 'Crypto Enthusiast',
        'avatar': 'https://api.dicebear.com/8.x/pixel-art/png?seed=$name'
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception('Gagal mendaftar: ${error['message']}');
    }
  }

  /// Menambahkan artikel ke bookmark.
  Future<void> addBookmark(String articleId, String token) async {
    await http.post(
      Uri.parse('$baseUrl/news/$articleId/bookmark'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Menghapus artikel dari bookmark.
  Future<void> removeBookmark(String articleId, String token) async {
    await http.delete(
      Uri.parse('$baseUrl/news/$articleId/bookmark'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Memeriksa status bookmark sebuah artikel.
  Future<bool> checkBookmarkStatus(String articleId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/news/$articleId/bookmark'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['isSaved'];
    }
    return false;
  }

  /// Mengambil semua artikel yang telah di-bookmark oleh pengguna.
  Future<List<Article>> getBookmarkedArticles() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Pengguna belum login. Silakan login untuk melihat bookmark.');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/news/bookmarks/list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> articlesData = responseData['data'];
      return articlesData.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat artikel yang disimpan');
    }
  }

  /// Mengambil artikel yang dibuat oleh pengguna yang sedang login.
  Future<List<Article>> getMyArticles() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Pengguna belum login');

    final response = await http.get(
      Uri.parse('$baseUrl/news/user/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      try {
        final dynamic decodedBody = json.decode(response.body);
        if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('data')) {
          final dynamic dataContent = decodedBody['data'];
          if (dataContent is Map<String, dynamic> && dataContent.containsKey('articles')) {
            final List<dynamic> articlesData = dataContent['articles'];
            return articlesData.map((json) => Article.fromJson(json)).toList();
          }
        }
        throw const FormatException('Format respons dari server tidak valid.');
      } catch (e) {
        print('Error saat parsing artikel saya: $e');
        throw Exception('Gagal memproses data dari server.');
      }
    } else {
      print('Gagal memuat artikel saya. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Gagal memuat artikel (Status: ${response.statusCode})');
    }
  }

  /// Membuat artikel baru.
  Future<void> createArticle(Map<String, dynamic> articleData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Pengguna belum login');

    final Map<String, dynamic> body = {
      "title": articleData["title"],
      "content": articleData["content"],
      "category": articleData["category"],
      "imageUrl": articleData["imageUrl"],
      "readTime": articleData["readTime"],
      "tags": (articleData["tags"] as List<String>),
      "isTrending": articleData["isTrending"],
    };

    final response = await http.post(
      Uri.parse('$baseUrl/news'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      print('Gagal membuat artikel. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Gagal membuat artikel');
    }
  }

  /// Mengupdate artikel yang sudah ada.
  Future<void> updateArticle(String articleId, Map<String, dynamic> articleData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Pengguna belum login');
    
    final Map<String, dynamic> body = {
      "title": articleData["title"],
      "content": articleData["content"],
      "category": articleData["category"],
      "imageUrl": articleData["imageUrl"],
      "readTime": articleData["readTime"],
      "tags": (articleData["tags"] as List<String>),
      "isTrending": articleData["isTrending"],
    };

    final response = await http.put(
      Uri.parse('$baseUrl/news/$articleId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      print('Gagal memperbarui artikel. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Gagal memperbarui artikel');
    }
  }

  /// Menghapus artikel.
  Future<void> deleteArticle(String articleId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Pengguna belum login');

    final response = await http.delete(
      Uri.parse('$baseUrl/news/$articleId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus artikel');
    }
  }
}