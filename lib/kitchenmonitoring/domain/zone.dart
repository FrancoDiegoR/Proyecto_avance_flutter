import '../../common/json_utils.dart';

class Zone {
  final int id;
  final String name;
  final String description;
  final String status;
  final double? gasLevel;
  final double? temperature;
  final int sensorCount;

  Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.gasLevel,
    this.temperature,
    required this.sensorCount,
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: toInt(json['id']),
        name: toText(json['name'], 'Zone'),
        description: toText(json['description']),
        status: toText(json['status'], 'Safe'),
        gasLevel: toDouble(json['gasLevel']),
        temperature: toDouble(json['temperature']),
        sensorCount: toInt(json['sensorCount']),
      );

  /// Copia con la ultima lectura de sus sensores (el backend no siempre actualiza la zona).
  Zone withReading(double? gas, double? temp) => Zone(
        id: id,
        name: name,
        description: description,
        status: status,
        gasLevel: gas ?? gasLevel,
        temperature: temp ?? temperature,
        sensorCount: sensorCount,
      );
}
