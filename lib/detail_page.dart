import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'article_model.dart';
import 'auth_service.dart';

class DetailPage extends StatefulWidget {
  final Article article;

  const DetailPage({super.key, required this.article});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _isBookmarked = false;
  bool _isLoadingBookmark = true;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  void _checkBookmark() async {
    setState(() {
      _isLoadingBookmark = true;
    });
    final token = await _authService.getToken();
    if (token != null) {
      try {
        final status = await _apiService.checkBookmarkStatus(widget.article.id, token);
        if (mounted) {
          setState(() {
            _isBookmarked = status;
          });
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingBookmark = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingBookmark = false;
        });
      }
    }
  }

  void _toggleBookmark() async {
    final token = await _authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to bookmark articles.')));
      return;
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      if (_isBookmarked) {
        await _apiService.addBookmark(widget.article.id, token);
      } else {
        await _apiService.removeBookmark(widget.article.id, token);
      }
    } catch (e) {
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update bookmark.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final publishedDate = DateFormat("d MMMM yyyy").format(DateTime.parse(widget.article.createdAt));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(widget.article.category,
                  style: const TextStyle(fontSize: 12, color: Colors.white, shadows: [Shadow(blurRadius: 10)])),
              background: Image.network(
                widget.article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image,
                        color: Colors.grey, size: 50),
                  );
                },
              ),
            ),
            actions: [
              _isLoadingBookmark
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )))
                  : IconButton(
                      icon: Icon(
                        _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: _toggleBookmark,
                    ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.article.author.avatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.article.author.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Published on $publishedDate',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    widget.article.content,
                    style: const TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}