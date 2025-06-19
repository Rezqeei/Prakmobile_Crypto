// lib/screens/my_articles_page.dart

import 'package:flutter/material.dart';
import 'package:prakmobile_crypto/auth_service.dart'; // Import AuthService
import 'package:prakmobile_crypto/login_page.dart'; // Import LoginPage
import '../api_service.dart';
import '../article_model.dart';
import 'edit_article_page.dart';

class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({super.key});

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService(); // Buat instance AuthService
  late Future<List<Article>> _myArticlesFuture;

  @override
  void initState() {
    super.initState();
    _loadMyArticles();
  }

  void _loadMyArticles() {
    setState(() {
      _myArticlesFuture = _apiService.getMyArticles();
    });
  }

  // Fungsi logout sudah dipindahkan ke profile_page.dart

  void _deleteArticle(String articleId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteArticle(articleId);
        _loadMyArticles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Saya'),
        // Tombol logout sudah dihapus dari sini
      ),
      body: FutureBuilder<List<Article>>(
        future: _myArticlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum membuat artikel.'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(article.title),
                  subtitle: Text(article.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditArticlePage(article: article),
                            ),
                          ).then((_) => _loadMyArticles());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteArticle(article.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditArticlePage()),
          ).then((_) => _loadMyArticles());
        },
        child: const Icon(Icons.add),
        tooltip: 'Buat Artikel Baru',
      ),
    );
  }
}