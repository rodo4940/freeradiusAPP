enum PppoeStatus {
  activo,
  inactivo,
  suspendido,
  desconocido,
}

class PppoeUser {
  const PppoeUser({
    required this.id,
    required this.username,
    required this.plan,
    required this.router,
    required this.status,
    required this.password,
  });

  final int id;
  final String username;
  final String plan;
  final String router;
  final PppoeStatus status;
  final String password;

  factory PppoeUser.fromJson(Map<String, dynamic> json) {
    int _parseId(dynamic value) {
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return PppoeUser(
      id: _parseId(json['id']),
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      router: json['router'] as String? ?? '',
      status: parsePppoeStatus(json['status'] as String? ?? ''),
    );
  }

  PppoeUser copyWith({
    int? id,
    String? username,
    String? plan,
    String? router,
    PppoeStatus? status,
    String? password,
  }) {
    return PppoeUser(
      id: id ?? this.id,
      username: username ?? this.username,
      plan: plan ?? this.plan,
      router: router ?? this.router,
      status: status ?? this.status,
      password: password ?? this.password,
    );
  }

  String get statusLabel {
    return switch (status) {
      PppoeStatus.activo => 'Activo',
      PppoeStatus.inactivo => 'Inactivo',
      PppoeStatus.suspendido => 'Suspendido',
      PppoeStatus.desconocido => 'Desconocido',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'plan': plan,
      'router': router,
      'status': switch (status) {
        PppoeStatus.activo => 'Activo',
        PppoeStatus.inactivo => 'Inactivo',
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
    case 'inactivo':
      return PppoeStatus.inactivo;
    case 'suspendido':
      return PppoeStatus.suspendido;
    default:
      return PppoeStatus.desconocido;
  }
}
