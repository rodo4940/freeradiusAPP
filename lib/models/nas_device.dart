class NasDevice {
  const NasDevice({
    required this.id,
    required this.shortname,
    required this.ipAddress,
    required this.type,
    required this.status,
    required this.secret,
    required this.description,
    this.ports,
  });

  final int? id;
  final String shortname;
  final String ipAddress;
  final String type;
  final String status;
  final String secret;
  final String description;
  final int? ports;

  factory NasDevice.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    int? parsePorts(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    final ip = (json['ipaddress'] ??
            json['nasname'] ??
            json['ip'] ??
            json['address']) as String? ??
        '';

    return NasDevice(
      id: parseId(json['id']),
      shortname: json['shortname'] as String? ?? '',
      ipAddress: ip,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      secret: json['secret'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ports: parsePorts(json['ports']),
    );
  }
}
