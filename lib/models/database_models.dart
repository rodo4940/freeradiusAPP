class DatabaseStatus {
  const DatabaseStatus({
    required this.status,
    required this.version,
    required this.port,
    required this.uptime,
  });

  final String status;
  final String version;
  final String port;
  final String uptime;

  factory DatabaseStatus.fromJson(Map<String, dynamic> json) {
    return DatabaseStatus(
      status: json['status'] as String? ?? '',
      version: json['version'] as String? ?? '',
      port: json['port']?.toString() ?? '—',
      uptime: json['uptime'] as String? ?? '',
    );
  }
}

class DatabaseSystemInfo {
  const DatabaseSystemInfo({
    required this.distro,
    required this.hostname,
    required this.dataPath,
    required this.configPath,
  });

  final String distro;
  final String hostname;
  final String dataPath;
  final String configPath;

  factory DatabaseSystemInfo.fromJson(Map<String, dynamic> json) {
    return DatabaseSystemInfo(
      distro: json['distro'] as String? ?? '',
      hostname: json['hostname'] as String? ?? '',
      dataPath: json['dataPath'] as String? ?? '',
      configPath: json['configPath'] as String? ?? '',
    );
  }
}

class DatabaseResourceUsage {
  const DatabaseResourceUsage({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
  });

  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;

  factory DatabaseResourceUsage.fromJson(Map<String, dynamic> json) {
    double parsePercent(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return DatabaseResourceUsage(
      cpuUsage: parsePercent(json['cpuUsage']),
      memoryUsage: parsePercent(json['memoryUsage']),
      diskUsage: parsePercent(json['diskUsage']),
    );
  }
}

class DatabaseTableInfo {
  const DatabaseTableInfo({
    required this.name,
    required this.records,
    required this.description,
  });

  final String name;
  final int? records;
  final String description;

  factory DatabaseTableInfo.fromJson(Map<String, dynamic> json) {
    return DatabaseTableInfo(
      name: json['name'] as String? ?? '',
      records: (json['records'] as num?)?.toInt(),
      description: json['description'] as String? ?? '',
    );
  }
}
