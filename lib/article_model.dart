// lib/article_model.dart

class Article {
  final String id;
  final String title;
  final String category;
  final String publishedAt;
  final String readTime;
  final String imageUrl;
  final String content;
  final Author author;
  final String createdAt;
  final List<String> tags;
  final bool isTrending;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    required this.readTime,
    required this.imageUrl,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.tags,
    required this.isTrending,
  });

  // GANTI FUNGSI DI BAWAH INI
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      publishedAt: json['publishedAt'],
      readTime: json['readTime'],
      imageUrl: json['imageUrl'],
      content: json['content'],
      // --- PERBAIKAN ---
      // Cek apakah 'author' null atau bukan. Jika null, buat Author default.
      author: json['author'] != null && json['author'] is Map<String, dynamic>
          ? Author.fromJson(json['author'])
          : Author(name: 'Unknown Author', title: 'Content Creator', avatar: 'https://via.placeholder.com/150'),
      // --- AKHIR PERBAIKAN ---
      createdAt: json['createdAt'],
      tags: List<String>.from(json['tags'] ?? []),
      isTrending: json['isTrending'] ?? false,
    );
  }
}

// Class Author tidak perlu diubah
class Author {
  final String name;
  final String title;
  final String avatar;

  Author({
    required this.name,
    required this.title,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] ?? 'Unknown Author',
      title: json['title'] ?? '',
      avatar: json['avatar'] ?? 'https://via.placeholder.com/150',
    );
  }
}