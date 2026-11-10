import 'package:flutter/material.dart';

import '../../common/json_utils.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/widgets.dart';
import '../domain/zone.dart';
import 'zone_detail_page.dart';

/// Fila de zona reutilizada por Home y Zones: icono, nombre, lecturas y estado.
class ZoneTile extends StatelessWidget {
  final Zone zone;

  const ZoneTile(this.zone, {super.key});

  @override
  Widget build(BuildContext context) {
    final readings = [
      if (zone.gasLevel != null) 'Gas ${formatNumber(zone.gasLevel)} ppm',
      if (zone.temperature != null) 'Temp ${formatNumber(zone.temperature)} °C',
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconTile(zoneIcon(zone.name)),
        title: Text(zone.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: readings.isEmpty ? null : Text(readings),
        trailing: StatusPill(zone.status, statusColor(zone.status)),
        // Igual que Navigator.push del ejemplo de contactos: abre el detalle con la zona elegida
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ZoneDetailPage(zone))),
      ),
    );
  }
}
