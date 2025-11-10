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
    int parseId(dynamic value) {
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return AppUser(
      id: parseId(json['id']),
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
