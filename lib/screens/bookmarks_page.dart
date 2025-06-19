import 'package:flutter/material.dart';
import '../api_service.dart';
import '../article_model.dart';
import '../detail_page.dart';
import '../widgets/shimer_loading.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final ApiService apiService = ApiService();
  
  // Mengelola state secara lokal
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }
  
  Future<void> _loadBookmarks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final articles = await apiService.getBookmarkedArticles();
      if (mounted) {
        setState(() {
          _bookmarkedArticles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat bookmark: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerLoadingList();
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }
    if (_bookmarkedArticles.isEmpty) {
      return const Center(child: Text('Anda belum menyimpan berita apapun.'));
    }

    return ListView.builder(
      itemCount: _bookmarkedArticles.length,
      itemBuilder: (context, index) {
        final article = _bookmarkedArticles[index];
        return ListTile(
          leading: Image.network(article.imageUrl, width: 100, fit: BoxFit.cover),
          title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(article.author.name),
          onTap: () async {
            // Tunggu hasil dari DetailPage
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(article: article))
            );

            // Jika ada perubahan (artikel di-unbookmark), hapus dari list lokal
            if (result == true && mounted) {
              setState(() {
                _bookmarkedArticles.removeWhere((a) => a.id == article.id);
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Tersimpan'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookmarks,
        child: _buildBody(),
      ),
    );
  }
}