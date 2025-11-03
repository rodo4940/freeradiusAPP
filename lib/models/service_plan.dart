class ServicePlan {
  const ServicePlan({
    required this.id,
    required this.groupname,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.poolName,
    required this.parent,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String groupname;
  final String downloadSpeed;
  final String uploadSpeed;
  final String poolName;
  final String parent;
  final String description;
  final String createdAt;

  factory ServicePlan.fromJson(Map<String, dynamic> json) {
    return ServicePlan(
      id: (json['id'] as num?)?.toInt() ?? 0,
      groupname: json['groupname'] as String? ?? '',
      downloadSpeed: json['downloadSpeed'] as String? ?? '',
      uploadSpeed: json['uploadSpeed'] as String? ?? '',
      poolName: json['poolName'] as String? ?? '',
      parent: json['parent'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
