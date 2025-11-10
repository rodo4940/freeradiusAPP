class DashboardStats {
  const DashboardStats({
    required this.activeClients,
    required this.totalClients,
    required this.activeRouters,
    required this.totalRouters,
    required this.usedPlans,
    required this.totalPlans,
  });

  final int activeClients;
  final int totalClients;
  final int activeRouters;
  final int totalRouters;
  final int usedPlans;
  final int totalPlans;
}

class ConnectionDataPoint {
  const ConnectionDataPoint({
    required this.month,
    required this.users,
    required this.newUsers,
    required this.successfulConnections,
  });

  final String month;
  final int users;
  final int newUsers;
  final int successfulConnections;

  factory ConnectionDataPoint.fromJson(Map<String, dynamic> json) {
    return ConnectionDataPoint(
      month: json['mes'] as String? ?? '',
      users: (json['usuarios'] as num?)?.toInt() ?? 0,
      newUsers: (json['nuevos'] as num?)?.toInt() ?? 0,
      successfulConnections: (json['exitosas'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlanDistributionItem {
  const PlanDistributionItem({
    required this.name,
    required this.value,
    this.colorHex,
  });

  final String name;
  final int value;
  final String? colorHex;

  factory PlanDistributionItem.fromJson(Map<String, dynamic> json) {
    return PlanDistributionItem(
      name: json['name'] as String? ?? '',
      value: (json['value'] as num?)?.toInt() ?? 0,
      colorHex: json['color'] as String?,
    );
  }
}
