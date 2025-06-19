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
  late Future<List<Article>> _bookmarkedArticlesFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }
  
  void _loadBookmarks() {
    setState(() {
      _bookmarkedArticlesFuture = apiService.getBookmarkedArticles();
    });
  }

  Future<void> _refreshBookmarks() async {
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Tersimpan'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookmarks,
        child: FutureBuilder<List<Article>>(
          future: _bookmarkedArticlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerLoadingList();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat bookmark: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Anda belum menyimpan berita apapun.'));
            }
            
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ListTile(
                  leading: Image.network(article.imageUrl, width: 100, fit: BoxFit.cover),
                  title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(article.author.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(article: article))
                    ).then((_) => _loadBookmarks()); // Muat ulang setelah kembali dari detail
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}