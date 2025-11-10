enum PppoeStatus {
  activo,
  suspendido,
  desconocido,
}

class PppoeUser {
  const PppoeUser({
    required this.id,
    required this.username,
    required this.plan,
    required this.status,
    required this.password,
  });

  final String id;
  final String username;
  final String plan;
  final PppoeStatus status;
  final String password;

  factory PppoeUser.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String? ?? '';
    final idValue = json['id'];
    return PppoeUser(
      id: (idValue is String && idValue.isNotEmpty)
          ? idValue
          : (idValue is num)
              ? idValue.toString()
              : username,
      username: username,
      password: json['password'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      status: parsePppoeStatus(json['status'] as String? ?? ''),
    );
  }

  PppoeUser copyWith({
    String? id,
    String? username,
    String? plan,
    PppoeStatus? status,
    String? password,
  }) {
    return PppoeUser(
      id: id ?? this.id,
      username: username ?? this.username,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      password: password ?? this.password,
    );
  }

  String get statusLabel {
    return switch (status) {
      PppoeStatus.activo => 'Activo',
      PppoeStatus.suspendido => 'Suspendido',
      PppoeStatus.desconocido => 'Desconocido',
    };
  }

  String get normalizedPlan {
    final cleaned = plan.replaceAll('_', ' ').trim();
    return cleaned.isEmpty ? plan : cleaned;
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'plan': plan,
      'status': switch (status) {
        PppoeStatus.activo => 'Activo',
        PppoeStatus.suspendido => 'Suspendido',
        PppoeStatus.desconocido => 'Desconocido',
      },
    };
  }
}

PppoeStatus parsePppoeStatus(String value) {
  switch (value.toLowerCase()) {
    case 'activo':
      return PppoeStatus.activo;
    case 'suspendido':
      return PppoeStatus.suspendido;
    default:
      return PppoeStatus.desconocido;
  }
}
