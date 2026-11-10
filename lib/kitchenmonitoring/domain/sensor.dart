import '../../common/json_utils.dart';

class Sensor {
  final int id;
  final String code;
  final String name;
  final String type;
  final int? zoneId;
  final String status;
  final double? battery;

  Sensor({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.zoneId,
    required this.status,
    this.battery,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
        id: toInt(json['id']),
        code: toText(json['code'], 'SG-${json['id']}'),
        name: toText(json['name']),
        type: toText(json['type'], 'Gas'),
        zoneId: json['zoneId'] == null ? null : toInt(json['zoneId']),
        status: toText(json['status'], 'Online'),
        battery: toDouble(json['battery'] ?? json['batteryLevel']),
      );

  bool get isOnline => status.toLowerCase() != 'offline';
}
