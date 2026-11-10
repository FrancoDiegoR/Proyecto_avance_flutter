import 'package:flutter/material.dart';

import '../../common/json_utils.dart';
import '../../common/session.dart';
import '../../iam/presentation/login_page.dart';
import '../../incidentpreventionnotification/data/alert_service.dart';
import '../../incidentpreventionnotification/domain/app_notification.dart';
import '../../kitchenmonitoring/data/monitoring_service.dart';
import '../../kitchenmonitoring/domain/sensor.dart';
import '../../kitchenmonitoring/domain/zone.dart';
import '../../kitchenmonitoring/presentation/zone_tile.dart';
import '../data/weather_service.dart';
import '../domain/weather.dart';
import 'app_theme.dart';
import 'widgets.dart';

/// Diseno 04: Home con el estado general, metricas, zonas y clima.
class HomePage extends StatefulWidget {
  final VoidCallback onSeeAllZones;

  const HomePage({required this.onSeeAllZones, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _monitoring = MonitoringService();
  final _alerts = AlertService();
  final _weatherService = WeatherService();

  List<Zone> _zones = [];
  List<Sensor> _sensors = [];
  int _pendingAlerts = 0;
  Weather? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final accountId = Session.accountId;
      final results = await Future.wait([
        _monitoring.getZonesWithLatestReading(accountId),
        _monitoring.getSensors(accountId),
        _alerts.getNotifications(accountId),
      ]);
      final weather = await _weatherService.getCurrent();

      setState(() {
        _zones = results[0] as List<Zone>;
        _sensors = results[1] as List<Sensor>;
        _pendingAlerts = (results[2] as List<AppNotification>).where((n) => !n.confirmed).length;
        _weather = weather;
      });
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar los datos.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Critical si alguna zona es critica, Warning si hay alguna en advertencia o alertas pendientes.
  String get _overallStatus {
    final statuses = _zones.map((z) => z.status.toLowerCase()).toList();
    if (statuses.contains('critical')) return 'Critical';
    if (statuses.contains('warning') || _pendingAlerts > 0) return 'Warning';
    return 'Safe';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días,';
    if (hour < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  void _logout() {
    Session.clear();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = Session.currentAccount?.firstName ?? '';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting, style: const TextStyle(color: AppColors.muted)),
                      Text(name.isEmpty ? 'SmartGas' : name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(tooltip: 'Actualizar', icon: const Icon(Icons.refresh), onPressed: _loadData),
                IconButton(tooltip: 'Cerrar sesión', icon: const Icon(Icons.logout), onPressed: _logout),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading && _zones.isEmpty)
              const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
            else if (_error != null && _zones.isEmpty)
              ErrorRetry(_error!, _loadData)
            else ...[
              _OverallStatusCard(
                status: _overallStatus,
                detail: '${_zones.length} zonas · ${_sensors.where((s) => s.isOnline).length} sensores en línea',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: StatCard('Zonas', '${_zones.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard('Sensores', '${_sensors.length}')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      'Alertas activas',
                      '$_pendingAlerts',
                      valueColor: _pendingAlerts == 0 ? AppColors.green : AppColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Zonas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  TextButton(onPressed: widget.onSeeAllZones, child: const Text('Ver todas')),
                ],
              ),
              // Primero las zonas con problemas
              ...([..._zones]..sort((a, b) => _order(a.status).compareTo(_order(b.status))))
                  .take(3)
                  .map((zone) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ZoneTile(zone))),
              if (_weather != null) _WeatherCard(_weather!),
            ],
          ],
        ),
      ),
    );
  }

  int _order(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return 0;
      case 'warning':
        return 1;
      default:
        return 2;
    }
  }
}

class _OverallStatusCard extends StatelessWidget {
  final String status;
  final String detail;

  const _OverallStatusCard({required this.status, required this.detail});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Critical' ? AppColors.red : status == 'Warning' ? AppColors.amber : AppColors.green;
    final title = status == 'Critical'
        ? 'Alerta crítica'
        : status == 'Warning'
            ? 'Requiere atención'
            : 'Todas las zonas seguras';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado general', style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Icon(status == 'Safe' ? Icons.verified_user_outlined : Icons.warning_amber_rounded, color: Colors.white, size: 44),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Weather weather;

  const _WeatherCard(this.weather);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const IconTile(Icons.wb_sunny_outlined, color: AppColors.orange),
        title: const Text('Exterior · Lima (Open-Meteo)', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        subtitle: Text(
          '${formatNumber(weather.temperature)} °C · Humedad ${formatNumber(weather.humidity)} % · '
          'Viento ${formatNumber(weather.wind)} ${weather.windUnit}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }
}
