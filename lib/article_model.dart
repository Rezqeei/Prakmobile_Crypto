
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
  final List<String> tags; // 1. TAMBAHKAN PROPERTI BARU

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
    required this.tags, // 2. TAMBAHKAN DI CONSTRUCTOR
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      publishedAt: json['publishedAt'],
      readTime: json['readTime'],
      imageUrl: json['imageUrl'],
      content: json['content'],
      author: Author.fromJson(json['author']),
      createdAt: json['createdAt'],
      // 3. AMBIL DATA TAGS DARI JSON
      tags: List<String>.from(json['tags'] ?? []), 
    );
  }
}

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