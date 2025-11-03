class RadiusStatusInfo {
  const RadiusStatusInfo({
    required this.isRunning,
    required this.uptime,
    required this.version,
    required this.configPath,
    required this.logPath,
    required this.port,
    required this.accountingPort,
  });

  final bool isRunning;
  final String uptime;
  final String version;
  final String configPath;
  final String logPath;
  final int port;
  final int accountingPort;

  factory RadiusStatusInfo.fromJson(Map<String, dynamic> json) {
    return RadiusStatusInfo(
      isRunning: json['isRunning'] as bool? ?? false,
      uptime: json['uptime'] as String? ?? '',
      version: json['version'] as String? ?? '',
      configPath: json['configPath'] as String? ?? '',
      logPath: json['logPath'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
      accountingPort: (json['accounting_port'] as num?)?.toInt() ?? 0,
    );
  }
}

class RadiusSystemInfo {
  const RadiusSystemInfo({
    required this.distro,
    required this.hostname,
    required this.networkInterface,
  });

  final String distro;
  final String hostname;
  final String networkInterface;

  factory RadiusSystemInfo.fromJson(Map<String, dynamic> json) {
    return RadiusSystemInfo(
      distro: json['distro'] as String? ?? '',
      hostname: json['hostname'] as String? ?? '',
      networkInterface: json['networkInterface'] as String? ?? '',
    );
  }
}

class RadiusResourceUsage {
  const RadiusResourceUsage({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
  });

  final int cpuUsage;
  final int memoryUsage;
  final int diskUsage;

  factory RadiusResourceUsage.fromJson(Map<String, dynamic> json) {
    return RadiusResourceUsage(
      cpuUsage: (json['cpuUsage'] as num?)?.toInt() ?? 0,
      memoryUsage: (json['memoryUsage'] as num?)?.toInt() ?? 0,
      diskUsage: (json['diskUsage'] as num?)?.toInt() ?? 0,
    );
  }
}
