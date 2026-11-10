import 'package:flutter/material.dart';

import '../../common/json_utils.dart';
import '../../common/session.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/widgets.dart';
import '../data/alert_service.dart';
import '../domain/app_notification.dart';
import '../domain/incident.dart';

/// Diseno 10: alertas con filtros Activas / Confirmadas / Todas y boton Confirmar.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final _service = AlertService();

  List<AppNotification> _notifications = [];
  Map<int, Incident> _incidents = {};
  String _filter = 'active';
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
      final notifications = await _service.getNotifications(accountId);
      final incidents = await _service.getIncidentsById(accountId);
      setState(() {
        _notifications = notifications;
        _incidents = incidents;
      });
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar las alertas.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm(AppNotification notification) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.confirm(notification.id);
      messenger.showSnackBar(const SnackBar(content: Text('Recepción confirmada.'), backgroundColor: AppColors.green));
      _loadData();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('No se pudo confirmar.'), backgroundColor: AppColors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _notifications.where((n) => !n.confirmed).toList();
    final confirmed = _notifications.where((n) => n.confirmed).toList();
    final visible = _filter == 'active' ? active : _filter == 'confirmed' ? confirmed : _notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Activas (${active.length})'),
                  selected: _filter == 'active',
                  onSelected: (_) => setState(() => _filter = 'active'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Confirmadas'),
                  selected: _filter == 'confirmed',
                  onSelected: (_) => setState(() => _filter = 'confirmed'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _filter == 'all',
                  onSelected: (_) => setState(() => _filter = 'all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading && _notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _notifications.isEmpty
                    ? ErrorRetry(_error!, _loadData)
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: visible.isEmpty
                            ? ListView(children: const [
                                Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Center(child: Text('No hay alertas en esta lista.')),
                                ),
                              ])
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: visible.length,
                                itemBuilder: (BuildContext context, int i) {
                                  final notification = visible[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AlertCard(
                                      notification: notification,
                                      incident: _incidents[notification.incidentId],
                                      onConfirm: () => _confirm(notification),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Las alertas también se envían como notificaciones push.',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta del diseno 10: borde izquierdo del color de la severidad, tipo, zona · valor y Confirmar.
class _AlertCard extends StatelessWidget {
  final AppNotification notification;
  final Incident? incident;
  final VoidCallback onConfirm;

  const _AlertCard({required this.notification, required this.incident, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final severity = incident?.severity ?? 'Critical';
    final color = statusColor(severity);
    final value = incident == null
        ? null
        : incident!.gas != null
            ? '${formatNumber(incident!.gas)} ppm (límite 50)'
            : incident!.temperature != null
                ? '${formatNumber(incident!.temperature)} °C (límite 45 °C)'
                : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusPill(severity, color),
                        const Spacer(),
                        Text(formatShortDate(notification.createdAt), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      incident?.typeLabel ?? notification.message,
                      style: TextStyle(fontSize: 17, fontWeight: notification.read ? FontWeight.w500 : FontWeight.bold),
                    ),
                    if (incident != null)
                      Text(
                        [incident!.zoneName, if (value != null) value].join(' · '),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    const SizedBox(height: 10),
                    notification.confirmed
                        ? const Row(children: [
                            Icon(Icons.check, color: AppColors.green, size: 18),
                            SizedBox(width: 4),
                            Text('Confirmada', style: TextStyle(color: AppColors.green)),
                          ])
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: const BorderSide(color: AppColors.blue),
                              backgroundColor: AppColors.blue.withValues(alpha: 0.08),
                            ),
                            onPressed: onConfirm,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Confirmar'),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
