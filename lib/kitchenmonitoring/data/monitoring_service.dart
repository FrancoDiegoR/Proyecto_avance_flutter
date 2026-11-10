import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../domain/sensor.dart';
import '../domain/sensor_reading.dart';
import '../domain/zone.dart';

/// Bounded context Kitchen Monitoring: zonas, sensores y lecturas.
class MonitoringService {
  Future<List<dynamic>> _getList(String path, int accountId) async {
    final response = await http.get(
      ApiConfig.uri(path, {'accountId': '$accountId'}),
      headers: ApiConfig.jsonHeaders,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return json.decode(response.body) as List<dynamic>;
  }

  Future<List<Zone>> getZones(int accountId) async =>
      (await _getList('zones', accountId)).map((item) => Zone.fromJson(item)).toList();

  Future<List<Sensor>> getSensors(int accountId) async =>
      (await _getList('sensors', accountId)).map((item) => Sensor.fromJson(item)).toList();

  /// Lecturas ordenadas de la mas nueva a la mas antigua.
  Future<List<SensorReading>> getReadings(int accountId) async {
    final readings = (await _getList('sensor-readings', accountId)).map((item) => SensorReading.fromJson(item)).toList();
    readings.sort((a, b) => (b.time ?? DateTime(0)).compareTo(a.time ?? DateTime(0)));
    return readings;
  }

  /// Zonas con la ultima lectura de cada una (gas y temperatura actuales).
  Future<List<Zone>> getZonesWithLatestReading(int accountId) async {
    final results = await Future.wait([getZones(accountId), getReadings(accountId)]);
    final zones = results[0] as List<Zone>;
    final readings = results[1] as List<SensorReading>;

    return zones.map((zone) {
      final latest = readings.where((r) => r.zoneId == zone.id);
      return latest.isEmpty ? zone : zone.withReading(latest.first.gas, latest.first.temperature);
    }).toList();
  }
}
