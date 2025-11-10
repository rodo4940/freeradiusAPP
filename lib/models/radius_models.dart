class RadiusStatusInfo {
  const RadiusStatusInfo({
    required this.isRunning,
    required this.uptime,
    required this.version,
    required this.configPath,
    required this.logPath,
    required this.port,
  });

  final bool isRunning;
  final String uptime;
  final String version;
  final String configPath;
  final String logPath;
  final int port;

  factory RadiusStatusInfo.fromJson(Map<String, dynamic> json) {
    return RadiusStatusInfo(
      isRunning: json['isRunning'] as bool? ?? false,
      uptime: json['uptime'] as String? ?? '',
      version: json['version'] as String? ?? '',
      configPath: json['configPath'] as String? ?? '',
      logPath: json['logPath'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
    );
  }
}

class RadiusSystemInfo {
  const RadiusSystemInfo({
    required this.distro,
    required this.hostname,
    required this.networkInterface,
    required this.ipAddress,
  });

  final String distro;
  final String hostname;
  final String networkInterface;
  final String ipAddress;

  factory RadiusSystemInfo.fromJson(Map<String, dynamic> json) {
    return RadiusSystemInfo(
      distro: json['distro'] as String? ?? '',
      hostname: json['hostname'] as String? ?? '',
      networkInterface: json['networkInterface'] as String? ?? '',
      ipAddress: json['ipaddress'] as String? ?? '',
    );
  }
}

class RadiusResourceUsage {
  const RadiusResourceUsage({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
  });

  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;

  factory RadiusResourceUsage.fromJson(Map<String, dynamic> json) {
    double parsePercent(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return RadiusResourceUsage(
      cpuUsage: parsePercent(json['cpuUsage']),
      memoryUsage: parsePercent(json['memoryUsage']),
      diskUsage: parsePercent(json['diskUsage']),
    );
  }
}
