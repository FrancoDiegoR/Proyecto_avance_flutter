import 'package:flutter/material.dart';

import '../../common/session.dart';
import '../../shared/presentation/widgets.dart';
import '../data/monitoring_service.dart';
import '../domain/zone.dart';
import 'zone_tile.dart';

/// Diseno 05: lista de zonas con filtros All / Safe / Warning / Critical.
class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  final _service = MonitoringService();

  List<Zone> _zones = [];
  String _filter = 'All';
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
      final zones = await _service.getZonesWithLatestReading(Session.accountId);
      setState(() => _zones = zones);
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar las zonas.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _count(String status) => _zones.where((z) => z.status.toLowerCase() == status.toLowerCase()).length;

  @override
  Widget build(BuildContext context) {
    final visible = _filter == 'All' ? _zones : _zones.where((z) => z.status.toLowerCase() == _filter.toLowerCase()).toList();
    final filters = {
      'All': 'Todas (${_zones.length})',
      'Safe': 'Seguras (${_count('Safe')})',
      'Warning': 'Advertencia (${_count('Warning')})',
      'Critical': 'Críticas (${_count('Critical')})',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zonas'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: filters.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: _filter == entry.key,
                          onSelected: (_) => setState(() => _filter = entry.key),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: _loading && _zones.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _zones.isEmpty
                    ? ErrorRetry(_error!, _loadData)
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        // ListView.builder como en el ejemplo de contactos del curso
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: visible.length,
                          itemBuilder: (BuildContext context, int i) =>
                              Padding(padding: const EdgeInsets.only(bottom: 10), child: ZoneTile(visible[i])),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
