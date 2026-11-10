import '../../common/json_utils.dart';

/// Notificacion de alerta (GET /notifications). Se llama AppNotification para no chocar con
/// la clase Notification de Flutter.
class AppNotification {
  final int id;
  final int? incidentId;
  final String message;
  final bool read;
  final bool confirmed;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    this.incidentId,
    required this.message,
    required this.read,
    required this.confirmed,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: toInt(json['id']),
        incidentId: json['incidentId'] == null ? null : toInt(json['incidentId']),
        message: toText(json['message'] ?? json['title'], 'SmartGas safety notification'),
        read: (json['read'] ?? json['isRead'] ?? false) == true,
        confirmed: (json['confirmed'] ?? json['isConfirmed'] ?? false) == true,
        createdAt: toDate(json['createdAt'] ?? json['sentAt']),
      );
}
