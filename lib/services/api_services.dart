import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:freeradius_app/models/app_user.dart';
import 'package:freeradius_app/models/nas_device.dart';
import 'package:freeradius_app/models/overview_models.dart';
import 'package:freeradius_app/models/pppoe_user.dart';
import 'package:freeradius_app/models/service_plan.dart';
import 'package:freeradius_app/utilities/constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PppoeUser>> fetchPppoeUsers() async {
    final data = await _getList('/clients');
    return data.map(PppoeUser.fromJson).toList(growable: false);
  }

  Future<void> createPppoeUser(Map<String, dynamic> payload) async {
    final uri = _buildUri('/clients');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    _throwIfFailed(response);
  }

  Future<void> updatePppoeUser(
    String username,
    Map<String, dynamic> payload,
  ) async {
    final uri = _buildUri('/clients/$username');
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    _throwIfFailed(response);
  }

  Future<void> deletePppoeUser(String username) async {
    final response = await _client.delete(
      _buildUri('/clients/$username'),
      headers: _headers,
    );
    _throwIfFailed(response);
  }

  Future<List<ServicePlan>> fetchPlans() async {
    final data = await _getList('/plans');
    return data.map(ServicePlan.fromJson).toList(growable: false);
  }

  Future<List<NasDevice>> fetchNasDevices() async {
    final data = await _getList('/nas');
    return data.map(NasDevice.fromJson).toList(growable: false);
  }

  Future<OverviewData> fetchOverview() async {
    final data = await _getMap('/overview');
    return OverviewData.fromJson(data);
  }

  Future<AppUser?> authenticateUser({
    required String username,
    required String password,
  }) async {
    final overview = await fetchOverview();
    try {
      return overview.users.firstWhere(
        (user) =>
            user.username.toLowerCase() == username.toLowerCase() &&
            user.password == password,
      );
    } on StateError {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await _get(path);
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

  Future<Map<String, dynamic>> _getMap(String path) async {
    final response = await _get(path);
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ApiException(
      statusCode: 500,
      body: 'Unexpected response format: expected JSON map.',
    );
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
    final base =
        (kApiBaseUrl.isEmpty ? 'http://127.0.0.1:8001/api' : kApiBaseUrl)
            .replaceFirst(RegExp(r'/$'), '');

    if (kIsWeb) {
      return base;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final uri = Uri.tryParse(base);
      final host = uri?.host ?? '';
      if (_isLoopbackHost(host)) {
        return base.replaceFirst(host, '10.0.2.2');
      }
    }

    return base;
  }

  bool _isLoopbackHost(String host) {
    if (host.isEmpty) return false;
    const aliases = {'localhost', '127.0.0.1', '0.0.0.0'};
    return aliases.contains(host);
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
