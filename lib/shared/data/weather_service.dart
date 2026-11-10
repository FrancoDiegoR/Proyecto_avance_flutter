import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../domain/weather.dart';

/// Clima exterior de Lima (el backend lo trae de Open-Meteo).
class WeatherService {
  Future<Weather?> getCurrent() async {
    try {
      final response = await http.get(
        ApiConfig.uri('external/weather/current', {'latitude': '-12.0464', 'longitude': '-77.0428'}),
        headers: ApiConfig.jsonHeaders,
      );
      if (response.statusCode != 200) return null;
      return Weather.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } catch (_) {
      // El clima es opcional: si falla, el Home se muestra sin esa tarjeta
      return null;
    }
  }
}
