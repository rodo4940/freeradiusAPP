class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String username;
  final String password;
  final String name;
  final String email;
  final String role;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}
