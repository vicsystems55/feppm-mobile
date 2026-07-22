import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import 'facility_models.dart';

class DashboardApiException implements Exception {
  const DashboardApiException(this.message);
  final String message;
}

class FacilityDashboardService {
  FacilityDashboardService({required this.accessToken, http.Client? client})
    : _client = client ?? http.Client();

  final String accessToken;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Future<DashboardSummary> fetchSummary() async {
    final payload = await _request('GET', '/dashboard');
    return DashboardSummary.fromJson(_map(payload['data']));
  }

  Future<List<FacilityTask>> fetchTasks(TaskFrequency frequency) async {
    final payload = await _request(
      'GET',
      '/checklists/my-tasks?frequency=${frequency.apiValue}',
    );
    final data = _map(payload['data']);
    return _list(data['tasks'])
        .map((item) => FacilityTask.fromChecklistJson(_map(item), frequency))
        .toList();
  }

  Future<void> startTask(String taskId) async {
    await _request('POST', '/checklists/tasks/$taskId/start');
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
      final response = method == 'POST'
          ? await _client
                .post(uri, headers: _headers, body: jsonEncode(body ?? {}))
                .timeout(const Duration(seconds: 20))
          : await _client
                .get(uri, headers: _headers)
                .timeout(const Duration(seconds: 20));
      final payload = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DashboardApiException(
          payload['message']?.toString() ?? 'Unable to load this information.',
        );
      }
      return payload;
    } on DashboardApiException {
      rethrow;
    } catch (_) {
      throw const DashboardApiException(
        'Could not connect to FEPPM. Check your connection and try again.',
      );
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final value = jsonDecode(body);
      return _map(value);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const [];
