import 'package:flutter/material.dart';

import '../../common/json_utils.dart';
import '../../common/session.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/widgets.dart';
import '../data/monitoring_service.dart';
import '../domain/sensor.dart';
import '../domain/sensor_reading.dart';
import '../domain/zone.dart';

/// Umbral de gas por defecto (el mismo que usa la app Android si no hay ajustes).
const double gasThreshold = 50;

/// Diseno 06: detalle de zona con su estado, ultimas lecturas y sensores.
class ZoneDetailPage extends StatefulWidget {
  final Zone zone;

  const ZoneDetailPage(this.zone, {super.key});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  final _service = MonitoringService();

  List<Sensor> _sensors = [];
  List<SensorReading> _readings = [];
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
      final results = await Future.wait([_service.getSensors(accountId), _service.getReadings(accountId)]);
      setState(() {
        _sensors = (results[0] as List<Sensor>).where((s) => s.zoneId == widget.zone.id).toList();
        _readings = (results[1] as List<SensorReading>).where((r) => r.zoneId == widget.zone.id).toList();
      });
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar los sensores.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Ultima lectura de un sensor (para "41 ppm" a la derecha de cada sensor).
  SensorReading? _latestFor(Sensor sensor) {
    for (final reading in _readings) {
      if (reading.sensorId == sensor.id) return reading;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    final color = statusColor(zone.status);
    final gas = _readings.isNotEmpty ? (_readings.first.gas ?? zone.gasLevel) : zone.gasLevel;
    final percent = gas == null ? null : (gas / gasThreshold * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(zone.name)),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarjeta de estado de la zona
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estado de la zona', style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text(zone.status, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text(
                          gas == null
                              ? 'Sin lecturas de gas'
                              : 'Gas en ${formatNumber(gas)} ppm · $percent % del umbral de ${gasThreshold.toInt()} ppm',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    zone.status.toLowerCase() == 'safe' ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Últimas lecturas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Card(
              child: _readings.isEmpty
                  ? const Padding(padding: EdgeInsets.all(16), child: Text('Aún no hay lecturas en esta zona.'))
                  : Column(
                      children: _readings
                          .take(5)
                          .map((r) => ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: (r.gas ?? 0) >= gasThreshold ? AppColors.red : AppColors.green,
                                ),
                                title: Text('Gas ${formatNumber(r.gas)} ppm · Temp ${formatNumber(r.temperature)} °C'),
                                trailing: Text(formatShortDate(r.time), style: const TextStyle(color: AppColors.muted)),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('Sensores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (_loading && _sensors.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_error != null)
              ErrorRetry(_error!, _loadData)
            else if (_sensors.isEmpty)
              const Text('Esta zona no tiene sensores.')
            else
              Card(
                child: Column(
                  children: _sensors.map((sensor) {
                    final latest = _latestFor(sensor);
                    final isTemp = sensor.type.toLowerCase().contains('temp');
                    final value = isTemp ? '${formatNumber(latest?.temperature)} °C' : '${formatNumber(latest?.gas)} ppm';
                    return ListTile(
                      leading: const IconTile(Icons.sensors),
                      title: Text('${sensor.code} · ${sensor.type}'),
                      subtitle: Text('Batería ${formatNumber(sensor.battery)} %'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          StatusPill(sensor.status, statusColor(sensor.status)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
