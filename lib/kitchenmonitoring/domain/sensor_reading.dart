import '../../common/json_utils.dart';

class SensorReading {
  final int? sensorId;
  final int? zoneId;
  final double? gas;
  final double? temperature;
  final DateTime? time;

  SensorReading({this.sensorId, this.zoneId, this.gas, this.temperature, this.time});

  factory SensorReading.fromJson(Map<String, dynamic> json) => SensorReading(
        sensorId: json['sensorId'] == null ? null : toInt(json['sensorId']),
        zoneId: json['zoneId'] == null ? null : toInt(json['zoneId']),
        gas: toDouble(json['gasValue'] ?? json['gasLevel'] ?? json['gas']),
        temperature: toDouble(json['temperatureValue'] ?? json['temperature']),
        time: toDate(json['timestamp'] ?? json['createdAt'] ?? json['recordedAt']),
      );
}
