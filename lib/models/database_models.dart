class DatabaseStatus {
  const DatabaseStatus({
    required this.status,
    required this.version,
    required this.port,
    required this.uptime,
    required this.connections,
    required this.queries,
    required this.size,
    required this.lastBackup,
  });

  final String status;
  final String version;
  final int port;
  final String uptime;
  final int connections;
  final int queries;
  final String size;
  final String lastBackup;

  factory DatabaseStatus.fromJson(Map<String, dynamic> json) {
    return DatabaseStatus(
      status: json['status'] as String? ?? '',
      version: json['version'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
      uptime: json['uptime'] as String? ?? '',
      connections: (json['connections'] as num?)?.toInt() ?? 0,
      queries: (json['queries'] as num?)?.toInt() ?? 0,
      size: json['size'] as String? ?? '',
      lastBackup: json['lastBackup'] as String? ?? '',
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

  final int cpuUsage;
  final int memoryUsage;
  final int diskUsage;

  factory DatabaseResourceUsage.fromJson(Map<String, dynamic> json) {
    return DatabaseResourceUsage(
      cpuUsage: (json['cpuUsage'] as num?)?.toInt() ?? 0,
      memoryUsage: (json['memoryUsage'] as num?)?.toInt() ?? 0,
      diskUsage: (json['diskUsage'] as num?)?.toInt() ?? 0,
    );
  }
}
