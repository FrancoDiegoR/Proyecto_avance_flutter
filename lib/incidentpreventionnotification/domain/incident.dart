import '../../common/json_utils.dart';

/// Incidente asociado a una alerta: da el tipo, la zona, el sensor y el valor detectado.
class Incident {
  final int id;
  final String type;
  final String zoneName;
  final String sensorCode;
  final String severity;
  final String status;
  final double? gas;
  final double? temperature;

  Incident({
    required this.id,
    required this.type,
    required this.zoneName,
    required this.sensorCode,
    required this.severity,
    required this.status,
    this.gas,
    this.temperature,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    final detected = toText(json['detectedValue']);
    // Si no llega gasLevel, se toma el numero de "Gas: 62 ppm" o "35 ppm"
    final gasMatch = RegExp(r'([\d.]+)\s*ppm', caseSensitive: false).firstMatch(detected);
    final tempMatch = RegExp(r'([\d.]+)\s*°C', caseSensitive: false).firstMatch(detected);
    return Incident(
      id: toInt(json['id']),
      type: toText(json['type'] ?? json['incidentType'] ?? json['title'], 'Incident'),
      zoneName: toText(json['zoneName'], 'Zone ${json['zoneId'] ?? '—'}'),
      sensorCode: toText(json['sensorCode']),
      severity: toText(json['severity'], 'Critical'),
      status: toText(json['status'], 'Active'),
      gas: toDouble(json['gasLevel']) ?? toDouble(gasMatch?.group(1)),
      temperature: toDouble(json['temperature']) ?? toDouble(tempMatch?.group(1)),
    );
  }

  /// "GasLeak" -> "Gas leak", "HighTemperature" -> "High temperature"
  String get typeLabel {
    final spaced = type.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ').trim();
    return spaced.isEmpty ? type : spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }
}
