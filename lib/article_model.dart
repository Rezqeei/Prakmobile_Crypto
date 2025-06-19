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
  final bool isTrending; // TAMBAHKAN PROPERTI INI

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
    required this.isTrending, // TAMBAHKAN DI CONSTRUCTOR
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
      tags: List<String>.from(json['tags'] ?? []),
      isTrending: json['isTrending'] ?? false, // AMBIL DATA isTrending DARI JSON
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