import 'package:flutter/material.dart';
import '../api_service.dart';
import '../article_model.dart';
import '../detail_page.dart';
import '../widgets/shimer_loading.dart';
import 'search_page.dart'; // Pastikan import ini ada

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService apiService = ApiService();
  // Mengelola state untuk artikel
  List<Article> _allArticles = [];
  List<Article> _featuredArticles = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      // Mengambil semua artikel dari API
      final articles = await apiService.getArticles();
      if (mounted) {
        setState(() {
          _allArticles = articles;
          // Mengambil 2 artikel pertama untuk bagian "Featured"
          _featuredArticles = articles.take(2).toList();
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const ShimmerLoadingList()
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _buildContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Infoin',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 28),
          onPressed: () {
            // Navigasi ke SearchPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              tabs: const [
                Tab(text: 'Headline'),
                Tab(text: 'Top Stories'),
                Tab(text: 'Similar News'),
              ],
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHeadlineTab(),
          const Center(child: Text('Konten Top Stories')),
          const Center(child: Text('Konten Similar News')),
        ],
      ),
    );
  }

  Widget _buildHeadlineTab() {
    return RefreshIndicator(
      onRefresh: _fetchArticles,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Featured',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFeaturedSection(),
          const SizedBox(height: 24),
          const Text(
            'All News',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildAllNewsSection(),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredArticles.length,
        itemBuilder: (context, index) {
          final article = _featuredArticles[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(article: article))),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  Image.network(
                    article.imageUrl,
                    width: 250,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 250, color: Colors.grey.shade300),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllNewsSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allArticles.length,
      itemBuilder: (context, index) {
        final article = _allArticles[index];
        return ArticleListItem(article: article);
      },
    );
  }
}

class ArticleListItem extends StatefulWidget {
  final Article article;
  const ArticleListItem({super.key, required this.article});

  @override
  State<ArticleListItem> createState() => _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem> {
  final ApiService _apiService = ApiService();
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final status = await _apiService.checkBookmarkStatus(widget.article.id);
      if (mounted) {
        setState(() {
          _isBookmarked = status;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBookmarked = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleBookmark() async {
    if (!mounted) return;

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      if (_isBookmarked) {
        await _apiService.addBookmark(widget.article.id);
      } else {
        await _apiService.removeBookmark(widget.article.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(article: widget.article))
        );
        if (result == true) {
          _checkBookmarkStatus();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.article.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 120, height: 120, color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined),
                    onPressed: _toggleBookmark,
                  ),
          ],
        ),
      ),
    );
  }
}