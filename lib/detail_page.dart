import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'article_model.dart';
// AuthService tidak lagi diperlukan di sini karena sudah ditangani oleh ApiService
// import 'auth_service.dart';

class DetailPage extends StatefulWidget {
  final Article article;

  const DetailPage({super.key, required this.article});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService _apiService = ApiService();
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
    try {
      // PERBAIKAN: Panggil fungsi tanpa token
      final status = await _apiService.checkBookmarkStatus(widget.article.id);
      if (mounted) {
        setState(() {
          _isBookmarked = status;
        });
      }
    } catch (e) {
      // Jika pengguna belum login, ApiService akan melempar Exception.
      // Kita bisa menangani UI di sini jika diperlukan, misal:
      // menampilkan ikon bookmark non-aktif.
      if (mounted) {
        setState(() {
          _isBookmarked = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookmark = false;
        });
      }
    }
  }

  void _toggleBookmark() async {
    // Logika untuk mengambil token manual dihapus
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      if (_isBookmarked) {
        // PERBAIKAN: Panggil fungsi tanpa token
        await _apiService.addBookmark(widget.article.id);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel berhasil ditambahkan ke bookmark.')));
        }
      } else {
        // PERBAIKAN: Panggil fungsi tanpa token
        await _apiService.removeBookmark(widget.article.id);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel berhasil dihapus dari bookmark.')));
        }
      }
    } catch (e) {
      // Jika gagal, kembalikan state UI ke semula
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      // Tampilkan pesan error yang lebih jelas dari ApiService
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}'))
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan createdAt tidak null sebelum parsing
    final publishedDate = widget.article.createdAt.isNotEmpty
        ? DateFormat("d MMMM yyyy", "id_ID").format(DateTime.parse(widget.article.createdAt))
        : "Tanggal tidak tersedia";

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
                              'Diterbitkan pada $publishedDate',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.article.readTime,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    widget.article.content,
                    style: const TextStyle(fontSize: 16.0, height: 1.6),
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