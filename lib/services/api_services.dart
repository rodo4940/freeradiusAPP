import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:freeradius_app/models/app_user.dart';
import 'package:freeradius_app/models/dashboard_models.dart';
import 'package:freeradius_app/models/database_models.dart';
import 'package:freeradius_app/models/nas_device.dart';
import 'package:freeradius_app/models/pppoe_user.dart';
import 'package:freeradius_app/models/radius_models.dart';
import 'package:freeradius_app/models/service_plan.dart';
import 'package:freeradius_app/utilities/constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PppoeUser>> fetchPppoeUsers() async {
    final response = await _get('/clients');
    final data = _decodeList(response);
    return data.map((item) => PppoeUser.fromJson(item)).toList();
  }

  Future<PppoeUser> createPppoeUser(Map<String, dynamic> payload) async {
    final uri = _buildUri('/clients');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    _throwIfFailed(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PppoeUser.fromJson(json);
  }

  Future<PppoeUser> updatePppoeUser(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final uri = _buildUri('/clients/$id');
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    _throwIfFailed(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PppoeUser.fromJson(json);
  }

  Future<void> deletePppoeUser(int id) async {
    final response = await _client.delete(_buildUri('/clients/$id'));
    _throwIfFailed(response);
  }

  Future<List<String>> fetchRouters() async {
    final response = await _get('/routers');
    final data = _decodeList(response);
    return data
        .map((item) => (item['name'] as String?) ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<List<ServicePlan>> fetchPlans() async {
    final response = await _get('/plans');
    final data = _decodeList(response);
    return data.map((item) => ServicePlan.fromJson(item)).toList();
  }

  Future<List<NasDevice>> fetchNasDevices() async {
    final response = await _get('/nasDevices');
    final data = _decodeList(response);
    return data.map((item) => NasDevice.fromJson(item)).toList();
  }

  Future<DashboardStats> fetchDashboardStats() async {
    final response = await _get('/dashboardStats');
    final data = _decodeList(response);
    if (data.isEmpty) {
      return const DashboardStats(
        activeClients: 0,
        disconnectedClients: 0,
        activeRouters: 0,
        disconnectedRouters: 0,
        totalBandwidth: '0 Mbps',
        todayConnections: 0,
      );
    }
    return DashboardStats.fromJson(data.first);
  }

  Future<List<ConnectionDataPoint>> fetchConnectionData() async {
    final response = await _get('/connectionData');
    final data = _decodeList(response);
    return data.map((item) => ConnectionDataPoint.fromJson(item)).toList();
  }

  Future<List<PlanDistributionItem>> fetchPlanDistribution() async {
    final response = await _get('/planDistribution');
    final data = _decodeList(response);
    return data
        .map((item) => PlanDistributionItem.fromJson(item))
        .toList();
  }

  Future<DatabaseStatus?> fetchDatabaseStatus() async {
    final response = await _get('/databaseStatus');
    final data = _decodeList(response);
    return data.isEmpty ? null : DatabaseStatus.fromJson(data.first);
  }

  Future<DatabaseSystemInfo?> fetchDatabaseSystemInfo() async {
    final response = await _get('/databaseSystemInfo');
    final data = _decodeList(response);
    return data.isEmpty ? null : DatabaseSystemInfo.fromJson(data.first);
  }

  Future<DatabaseResourceUsage?> fetchDatabaseResourceUsage() async {
    final response = await _get('/databaseResourceUsage');
    final data = _decodeList(response);
    return data.isEmpty ? null : DatabaseResourceUsage.fromJson(data.first);
  }

  Future<RadiusStatusInfo?> fetchRadiusStatus() async {
    final response = await _get('/radiusStatus');
    final data = _decodeList(response);
    return data.isEmpty ? null : RadiusStatusInfo.fromJson(data.first);
  }

  Future<RadiusSystemInfo?> fetchRadiusSystemInfo() async {
    final response = await _get('/radiusSystemInfo');
    final data = _decodeList(response);
    return data.isEmpty ? null : RadiusSystemInfo.fromJson(data.first);
  }

  Future<RadiusResourceUsage?> fetchRadiusResourceUsage() async {
    final response = await _get('/radiusResourceUsage');
    final data = _decodeList(response);
    return data.isEmpty ? null : RadiusResourceUsage.fromJson(data.first);
  }

  Future<AppUser?> authenticateUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.get(
        _buildUri(
          '/users',
          queryParameters: {
            'username': username,
            'password': password,
          },
        ),
        headers: _headers,
      );
      _throwIfFailed(response);

      final decoded = jsonDecode(response.body);
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          return AppUser.fromJson(first);
        }
      }
      return null;
    } on http.ClientException catch (error) {
      throw ApiException(
        statusCode: -1,
        body: error.message,
        uri: error.uri,
      );
    }
  }

  Future<http.Response> _get(String path) async {
    try {
      final response = await _client.get(_buildUri(path), headers: _headers);
      _throwIfFailed(response);
      return response;
    } on http.ClientException catch (error) {
      throw ApiException(
        statusCode: -1,
        body: error.message,
        uri: error.uri,
      );
    }
  }

  Uri _buildUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final sanitizedPath = path.startsWith('/') ? path : '/$path';
    final base = _resolvedBaseUrl;
    final uri = Uri.parse('$base$sanitizedPath');
    if (queryParameters == null) {
      return uri;
    }
    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  String get _resolvedBaseUrl {
    final base = (kApiBaseUrl.isEmpty ? 'http://localhost:3000' : kApiBaseUrl)
        .replaceFirst(RegExp(r'/$'), '');

    if (kIsWeb) {
      return base;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (base.contains('localhost')) {
          return base.replaceFirst('localhost', '10.0.2.2');
        }
        return base;
      default:
        return base;
    }
  }

  void _throwIfFailed(http.Response response) {
    final code = response.statusCode;
    if (code < 200 || code >= 300) {
      throw ApiException(
        statusCode: code,
        body: response.body,
        uri: response.request?.url,
      );
    }
  }

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    }

    throw const ApiException(
      statusCode: 500,
      body: 'Unexpected response format: expected JSON array.',
    );
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    this.body,
    this.uri,
  });

  final int statusCode;
  final String? body;
  final Uri? uri;

  @override
  String toString() {
    final buffer = StringBuffer('ApiException(statusCode: $statusCode');
    if (uri != null) {
      buffer.write(', uri: $uri');
    }
    if (body != null && body!.isNotEmpty) {
      buffer.write(', body: $body');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

final ApiService apiService = ApiService();
