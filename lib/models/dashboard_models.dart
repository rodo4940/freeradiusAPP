class DashboardStats {
  const DashboardStats({
    required this.activeClients,
    required this.disconnectedClients,
    required this.activeRouters,
    required this.disconnectedRouters,
    required this.totalBandwidth,
    required this.todayConnections,
  });

  final int activeClients;
  final int disconnectedClients;
  final int activeRouters;
  final int disconnectedRouters;
  final String totalBandwidth;
  final int todayConnections;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeClients: (json['activeClients'] as num?)?.toInt() ?? 0,
      disconnectedClients: (json['disconnectedClients'] as num?)?.toInt() ?? 0,
      activeRouters: (json['activeRouters'] as num?)?.toInt() ?? 0,
      disconnectedRouters:
          (json['disconnectedRouters'] as num?)?.toInt() ?? 0,
      totalBandwidth: json['totalBandwidth'] as String? ?? '0 Mbps',
      todayConnections: (json['todayConnections'] as num?)?.toInt() ?? 0,
    );
  }
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
    required this.color,
  });

  final String name;
  final int value;
  final String color;

  factory PlanDistributionItem.fromJson(Map<String, dynamic> json) {
    return PlanDistributionItem(
      name: json['name'] as String? ?? '',
      value: (json['value'] as num?)?.toInt() ?? 0,
      color: json['color'] as String? ?? '#cccccc',
    );
  }
}
