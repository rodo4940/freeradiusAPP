class ServicePlan {
  const ServicePlan({
    required this.id,
    required this.groupname,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  final int id;
  final String groupname;
  final String downloadSpeed;
  final String uploadSpeed;

  factory ServicePlan.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic value) {
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return ServicePlan(
      id: parseId(json['id']),
      groupname: json['groupname'] as String? ?? '',
      downloadSpeed: json['downloadSpeed'] as String? ?? '',
      uploadSpeed: json['uploadSpeed'] as String? ?? '',
    );
  }

  String get normalizedName => groupname.replaceAll('_', ' ').trim();

  Map<String, dynamic> toPayload() {
    return {
      'groupname': groupname,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
    };
  }
}
