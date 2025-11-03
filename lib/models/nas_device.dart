class NasDevice {
  const NasDevice({
    required this.id,
    required this.shortname,
    required this.ipAddress,
    required this.description,
    required this.status,
    required this.type,
    required this.server,
  });

  final String id;
  final String shortname;
  final String ipAddress;
  final String description;
  final String status;
  final String type;
  final String server;

  factory NasDevice.fromJson(Map<String, dynamic> json) {
    return NasDevice(
      id: '${json['id']}',
      shortname: json['shortname'] as String? ?? '',
      ipAddress: json['ipaddress'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      server: json['server'] as String? ?? '',
    );
  }
}
