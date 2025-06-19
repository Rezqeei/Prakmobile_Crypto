import 'package:flutter/material.dart';
import '../api_service.dart';
import '../article_model.dart';
import '../detail_page.dart';
import '../auth_service.dart';
import '../login_page.dart';
import '../widgets/shimer_loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _searchController.addListener(_filterArticles);
  }

  Future<void> _fetchArticles() async {
    if (mounted) setState(() {_isLoading = true; _error = '';});
    try {
      final articles = await apiService.getArticles();
      if (mounted) {
        setState(() {
          _allArticles = articles;
          _filteredArticles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat artikel: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArticles = _allArticles.where((article) {
        return article.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Crypto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().deleteToken();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan judul...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _buildArticleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList() {
    if (_isLoading) return const ShimmerLoadingList();
    if (_error.isNotEmpty) return Center(child: Text(_error));
    if (_filteredArticles.isEmpty) return const Center(child: Text('Tidak ada artikel yang ditemukan.'));

    return RefreshIndicator(
      onRefresh: _fetchArticles,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 8.0),
        itemCount: _filteredArticles.length,
        itemBuilder: (context, index) {
          final article = _filteredArticles[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(article: article))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    article.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey[800], child: const Icon(Icons.broken_image)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            CircleAvatar(backgroundImage: NetworkImage(article.author.avatar), radius: 12),
                            const SizedBox(width: 8.0),
                            Expanded(child: Text(article.author.name, style: Theme.of(context).textTheme.bodySmall)),
                            Text(article.publishedAt, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}