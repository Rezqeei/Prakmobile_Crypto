// lib/models/user_model.dart

class User {
  final String id;
  final String name;
  final String email;
  final String title;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.title,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // API mungkin mengembalikan data user di dalam nested object 'user'
    final userData = json['user'] ?? json;
    return User(
      id: userData['_id'] ?? '',
      name: userData['name'] ?? 'No Name',
      email: userData['email'] ?? 'no-email@example.com',
      title: userData['title'] ?? 'No Title',
      avatar: userData['avatar'] ?? 'https://via.placeholder.com/150',
    );
  }
}