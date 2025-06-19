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
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      title: json['title'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}