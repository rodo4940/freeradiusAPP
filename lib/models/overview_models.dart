import 'package:freeradius_app/models/app_user.dart';
import 'package:freeradius_app/models/dashboard_models.dart';
import 'package:freeradius_app/models/database_models.dart';
import 'package:freeradius_app/models/nas_device.dart';
import 'package:freeradius_app/models/radius_models.dart';

class OverviewData {
  const OverviewData({
    required this.users,
    required this.nasDevices,
    required this.connectionData,
    required this.databaseStatus,
    required this.databaseSystemInfo,
    required this.databaseResourceUsage,
    required this.databaseTables,
    required this.radiusStatus,
    required this.radiusSystemInfo,
    required this.radiusResourceUsage,
  });

  final List<AppUser> users;
  final List<NasDevice> nasDevices;
  final List<ConnectionDataPoint> connectionData;
  final List<DatabaseStatus> databaseStatus;
  final List<DatabaseSystemInfo> databaseSystemInfo;
  final List<DatabaseResourceUsage> databaseResourceUsage;
  final List<DatabaseTableInfo> databaseTables;
  final List<RadiusStatusInfo> radiusStatus;
  final List<RadiusSystemInfo> radiusSystemInfo;
  final List<RadiusResourceUsage> radiusResourceUsage;

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(
      String key,
      T Function(Map<String, dynamic>) mapper,
    ) {
      final raw = json[key];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(mapper)
            .toList(growable: false);
      }
      return const [];
    }

    return OverviewData(
      users: parseList('users', AppUser.fromJson),
      nasDevices: parseList('nasDevices', NasDevice.fromJson),
      connectionData:
          parseList('connectionData', ConnectionDataPoint.fromJson),
      databaseStatus: parseList('databaseStatus', DatabaseStatus.fromJson),
      databaseSystemInfo:
          parseList('databaseSystemInfo', DatabaseSystemInfo.fromJson),
      databaseResourceUsage: parseList(
        'databaseResourceUsage',
        DatabaseResourceUsage.fromJson,
      ),
      databaseTables:
          parseList('databaseTables', DatabaseTableInfo.fromJson),
      radiusStatus: parseList('radiusStatus', RadiusStatusInfo.fromJson),
      radiusSystemInfo:
          parseList('radiusSystemInfo', RadiusSystemInfo.fromJson),
      radiusResourceUsage: parseList(
        'radiusResourceUsage',
        RadiusResourceUsage.fromJson,
      ),
    );
  }
}
