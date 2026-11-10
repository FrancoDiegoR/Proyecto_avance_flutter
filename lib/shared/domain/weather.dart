import '../../common/json_utils.dart';

class Weather {
  final double? temperature;
  final double? humidity;
  final double? wind;
  final String windUnit;

  Weather({this.temperature, this.humidity, this.wind, required this.windUnit});

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        temperature: toDouble(json['temperature']),
        humidity: toDouble(json['relativeHumidity']),
        wind: toDouble(json['windSpeed']),
        windUnit: toText(json['windSpeedUnit'], 'km/h'),
      );
}
