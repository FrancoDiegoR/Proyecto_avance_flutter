import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../domain/app_notification.dart';
import '../domain/incident.dart';

/// Bounded context Incident Prevention & Notification: alertas que recibe el usuario.
class AlertService {
  Future<List<AppNotification>> getNotifications(int accountId) async {
    final response = await http.get(
      ApiConfig.uri('notifications', {'accountId': '$accountId'}),
      headers: ApiConfig.jsonHeaders,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final list = (json.decode(response.body) as List<dynamic>).map((item) => AppNotification.fromJson(item)).toList();
    list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return list;
  }

  /// Los incidentes dan el tipo, la zona y el valor de cada alerta.
  Future<Map<int, Incident>> getIncidentsById(int accountId) async {
    final response = await http.get(
      ApiConfig.uri('incidents', {'accountId': '$accountId'}),
      headers: ApiConfig.jsonHeaders,
    );
    if (response.statusCode != 200) return {};
    final incidents = (json.decode(response.body) as List<dynamic>).map((item) => Incident.fromJson(item));
    return {for (final incident in incidents) incident.id: incident};
  }

  /// "Confirm" del diseno 10: PATCH /notifications/{id}/confirm
  Future<void> confirm(int notificationId) async {
    final response = await http.patch(
      ApiConfig.uri('notifications/$notificationId/confirm'),
      headers: ApiConfig.jsonHeaders,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}
