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
    required this.adminPassword,
    required this.pppoePassword,
    required this.plan,
    required this.router,
    required this.ipAddress,
    required this.status,
    required this.lastConnection,
  });

  final int id;
  final String username;
  final String adminPassword;
  final String pppoePassword;
  final String plan;
  final String router;
  final String ipAddress;
  final PppoeStatus status;
  final String? lastConnection;

  factory PppoeUser.fromJson(Map<String, dynamic> json) {
    return PppoeUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      adminPassword: json['password'] as String? ?? '',
      pppoePassword: json['pppoePassword'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      router: json['router'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '',
      status: parsePppoeStatus(json['status'] as String? ?? ''),
      lastConnection: json['lastConnection'] as String?,
    );
  }

  PppoeUser copyWith({
    int? id,
    String? username,
    String? adminPassword,
    String? pppoePassword,
    String? plan,
    String? router,
    String? ipAddress,
    PppoeStatus? status,
    String? lastConnection,
  }) {
    return PppoeUser(
      id: id ?? this.id,
      username: username ?? this.username,
      adminPassword: adminPassword ?? this.adminPassword,
      pppoePassword: pppoePassword ?? this.pppoePassword,
      plan: plan ?? this.plan,
      router: router ?? this.router,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      lastConnection: lastConnection ?? this.lastConnection,
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
      'password': adminPassword,
      'pppoePassword': pppoePassword,
      'plan': plan,
      'router': router,
      'ipAddress': ipAddress,
      'status': switch (status) {
        PppoeStatus.activo => 'Activo',
        PppoeStatus.inactivo => 'Inactivo',
        PppoeStatus.suspendido => 'Suspendido',
        PppoeStatus.desconocido => 'Desconocido',
      },
      if (lastConnection != null) 'lastConnection': lastConnection,
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
